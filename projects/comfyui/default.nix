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

    mkComfyUIVariant = let
      defaultBasePath = "/var/lib/comfyui";
    in
      { models
      , customNodes
      , inputPath ? "${defaultBasePath}/input"
      , outputPath ? "${defaultBasePath}/output"
      , tempPath ? "${defaultBasePath}/temp"
      , userPath ? "${defaultBasePath}/user"
      , ...
      }@args: let
      plugins = {
        customNodes = let
          deps = nodes: with builtins; lib.pipe nodes [
            attrValues
            (map (v: v.dependencies))
            concatLists
          ];
        in (pkgs.linkFarm "comfyui-custom-nodes" customNodes)
          .overrideAttrs (old: old // { dependencies = deps customNodes; });

        models = let
          inherit (lib.attrsets) concatMapAttrs;
          concatMapModels = f: concatMapAttrs (type: concatMapAttrs (f type));
          toNamePath = concatMapModels (type: name: fetched: {
            "${type}/${name}.${fetched.format}" = fetched.path;
          });
        in pkgs.linkFarm "comfyui-models" (toNamePath models);
      };
    in pkgs.callPackage ./package.nix ({
      # must make these explicit or they'll simply not be passed in
      inherit inputPath outputPath tempPath userPath;
    } // args // plugins);

    perGPUVendor = f: lib.attrsets.mergeAttrsList (builtins.map f ["amd" "nvidia"]);

  in perGPUVendor (vendor: let
      python3 = python3Variants."${vendor}".python;
      withConfig = cfg: mkComfyUIVariant ({ inherit python3; } // cfg);
      withPlugins = f: g: withConfig {
        models = f models;
        customNodes = g customNodes;
      };
      withModels = f: withPlugins f (_: {});
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
      customNodes = import ./custom-nodes { inherit lib pkgs; };
      models = import ./models { inherit (pkgs) fetchurl; inherit lib; };
    in {
      legacyPackages."${pkgs.system}".comfyui."${vendor}" = {
        inherit
          withConfig
          withModels
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
