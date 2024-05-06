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

    customNodes = import ./custom-nodes { inherit lib pkgs; };
    models = import ./models { inherit (pkgs) fetchurl; inherit lib; };

    # we require a python3 with an appropriately overriden package set depending on GPU
    mkComfyUIVariant = python3: args:
      pkgs.callPackage ./package.nix ({ inherit python3; } // args);

    # everything here needs to be parametrised over gpu vendor
    legacyPkgs = vendor: let
      # withConfig ::
      #   { models :: attrsOf fetchedModels
      #   , customNodes :: attrsOf fetchedCustomNodes
      #   , inputPath :: str
      #   , outputPath :: str
      #   , tempPath :: str
      #   , userPath :: str
      #   , ...
      #   }
      #   -> drv
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
        (models: f models // import ./models/krita-ai-plugin.nix models)
        (import ./custom-nodes/krita-ai-plugin.nix);
    in {
      inherit
        customNodes
        models
        withConfig
        withPlugins;
      krita-server = krita-server (_: {}) // {
        # is this a bad pattern?
        withExtraModels = krita-server;
      };
    };
  in {
    legacyPackages.comfyui.amd = legacyPkgs "amd";
    legacyPackages.comfyui.nvidia = legacyPkgs "nvidia";

    packages = {
      krita-comfyui-server-amd = (legacyPkgs "amd").krita-server;
      krita-comfyui-server-nvidia = (legacyPkgs "nvidia").krita-server;
    };
  };

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
