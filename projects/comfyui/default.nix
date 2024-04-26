{ config, lib, withSystem, ... }:

let
  l = lib // config.flake.lib;
  inherit (config.flake) overlays;
in

{
  perSystem = { config, pkgs, comfyuiCfg, ... }:
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

    mkComfyUIVariant = args:
      pkgs.callPackage ./package.nix ({
        inherit (comfyuiCfg)
          models
          customNodes
          modelsPath
          inputPath
          outputPath
          tempPath
          userPath;
      } // args);
  in {
    packages = {
      comfyui-amd = mkComfyUIVariant {
        python3 = python3Variants.amd.python;
      };
      comfyui-nvidia = mkComfyUIVariant {
        python3 = python3Variants.nvidia.python;
      };
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
