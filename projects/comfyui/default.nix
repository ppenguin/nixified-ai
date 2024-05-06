{ config, lib, withSystem, ... }:

let
  l = lib // config.flake.lib;
  inherit (config.flake) overlays;
in

{
  perSystem = { config, pkgs, lib, ... }:
  let
    commonOverlays = [
      # TODO: identify what we actually need
      (l.overlays.callManyPackages [
        ../../packages/mediapipe
        ../../packages/accelerate
      ])
      # what gives us a python with the overlays actually applied
      overlays.python-pythonFinal
    ];

    python3Variants = {
      amd = l.overlays.applyOverlays pkgs.python3Packages (commonOverlays ++ [
        overlays.python-torchRocm
      ]);
      nvidia = l.overlays.applyOverlays pkgs.python3Packages (commonOverlays ++ [
        # FIXME: temporary standin for practical purposes.
        # They're prebuilt and come with cuda support.
        (final: prev: {
          torch = prev.torch-bin;
          torchvision = prev.torchvision-bin;
        })
        # use this when things stabilise and we feel ready to build the whole thing
        # overlays.python-torchCuda
      ]);
    };

    # we require a python3 with an appropriately overriden package set depending on GPU
    mkComfyUIVariant = python3: args:
      pkgs.callPackage ./package.nix ({ inherit python3; } // args);

    perGPUVendor = f: lib.attrsets.mergeAttrsList (builtins.map f ["amd" "nvidia"]);

    customNodes = import ./custom-nodes { inherit lib pkgs; };
    models = import ./models { inherit (pkgs) fetchurl; inherit lib; };

  in {
    legacyPackages.comfyui = { inherit models customNodes; };
  } // perGPUVendor (vendor: let
      # withConfig :: { models :: attrsOf fetchedModels, customNodes :: attrsOf fetchedCustomNodes }
      # where
      #   `attrsOf fetchedModels` here is the type of what is in ./models/default.nix, i.e
      #   a three levels deep attrset of the form
      #     `{ "${type}" = { "${pname-minus-ext}" = fetchModel model; ... }; ... }`
      #     where
      #       `model = { format = _; url = _; sha256 = _; }`
      #       `fetchModel model :: { name :: str, format :: str, path :: str }`
      #       `fetchModel` comes from `./models/fetch-model.nix`
      #   `fetchedCustomNodes :: attrsOf drv` (see ./custom-nodes/default.nix):
      withConfig = mkComfyUIVariant python3Variants."${vendor}".python;
      withPlugins = f: g: withConfig {
        models = f models;
        customNodes = g customNodes;
      };
      # we define this in terms of `withPlugins` to serve as an example of its usage
      krita-server = f: withPlugins
        (models: f models // {
          checkpoints = {
            inherit (models.checkpoints)
              DreamShaper_8_pruned
              juggernautXL_version6Rundiffusion
              realisticVisionV51_v51VAE;
          };
          inpaint = {
            inherit (models.inpaint)
              fooocus_inpaint_head
              "inpaint_v26.fooocus"
              MAT_Places512_G_fp16;
          };
          "clip_vision/sd1.5" = {
            inherit (models."clip_vision/sd1.5")
              model;
          };
          controlnet = {
            inherit (models.controlnet)
              control_lora_rank128_v11f1e_sd15_tile_fp16
              control_v11p_sd15_inpaint_fp16;
          };
          ipadapter = {
            inherit (models.ipadapter)
              ip-adapter_sd15
              ip-adapter_sdxl_vit-h;
          };
          loras = {
            inherit (models.loras)
              lcm-lora-sdv1-5
              lcm-lora-sdxl;
          };
          upscale_models = {
            inherit (models.upscale_models)
              OmniSR_X2_DIV2K
              OmniSR_X3_DIV2K
              OmniSR_X4_DIV2K;
          };
        })
        (customNodes: {
          inherit (customNodes)
            controlnet-aux
            inpaint-nodes
            ipadapter-plus
            tooling-nodes
            ultimate-sd-upscale;
        });
    in {
      legacyPackages.comfyui."${vendor}" = {
        inherit
          withConfig
          withPlugins;
        krita-server = krita-server (_: {}) // {
          # is this a bad pattern?
          withExtraModels = krita-server;
        };
        # is this better or worse?
        # kritaServerWithExtraModels = krita-server;
      };

      packages = {
        "krita-comfyui-server-${vendor}" = krita-server (_: {});
      };
  });

  flake.nixosModules = let
    packageModule = pkgAttrName: { pkgs, ... }: {
      services.comfyui.package = withSystem pkgs.system (
        { config, ... }: lib.mkOptionDefault config.packages.${pkgAttrName}
      );
    };
  in {
    comfyui = ./nixos;
    comfyui-amd = {
      imports = [
        config.flake.nixosModules.comfyui
        (packageModule "comfyui-amd")
      ];
    };
    comfyui-nvidia = {
      imports = [
        config.flake.nixosModules.comfyui
        (packageModule "comfyui-nvidia")
      ];
    };
  };
}
