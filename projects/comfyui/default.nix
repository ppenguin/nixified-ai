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
      ])
      # what gives us a python with the cuda/rocm torch package override
      overlays.python-pythonFinal
    ];

    python3Variants = {
      amd = l.overlays.applyOverlays pkgs.python3Packages (commonOverlays ++ [
        overlays.python-torchRocm
      ]);
      # temp; see below
      # nvidia = l.overlays.applyOverlays pkgs.python3Packages (commonOverlays ++ [
      #   overlays.python-torchCuda
      # ]);
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
        # FIXME: temporary standin for practical purposes.
        python3 = pkgs.python3Packages.python.override {
          packageOverrides = final: prev: {
            torch = prev.torch-bin;
            torchvision = prev.torchvision-bin;
          };
        };
        # use this instead if you want to spend a day compiling. (please cachix the result)
        # python3 = python3Variants.nvidia.python;
      };

      # comfyui-krita-amd = _;
      # comfyui-krita-nvidia = _;
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
