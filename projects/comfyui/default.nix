{ config, inputs, lib, withSystem, ... }:

let
  l = lib // config.flake.lib;
  inherit (config.flake) overlays;
in

{
  perSystem = { config, pkgs, ... }:
  let
    commonOverlays = [
      (l.overlays.callManyPackages [
        ../../packages/mediapipe
      ])
      overlays.python-pythonFinal
    ];

    python3Variants = {
      amd = l.overlays.applyOverlays pkgs.python3Packages (commonOverlays ++ [
        overlays.python-torchRocm
      ]);
      nvidia = l.overlays.applyOverlays pkgs.python3Packages (commonOverlays ++ [
        overlays.python-torchCuda
      ]);
    };

    mkComfyUIVariant = pkgs.callPackage ./package.nix;
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
