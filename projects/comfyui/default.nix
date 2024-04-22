{ config, inputs, lib, withSystem, ... }:

let
  l = lib // config.flake.lib;
  inherit (config.flake) overlays;
in

{
  perSystem = { config, pkgs, ... }:
  let
    ## FIXME: this is mindlessly copy-pasted from the invokeai counterpart; look it over
    commonOverlays = [
      overlays.python-fixPackages
      (l.overlays.callManyPackages [
        ../../packages/mediapipe
        ../../packages/safetensors
        ../../packages/easing-functions
        ../../packages/dynamicprompts
        ../../packages/controlnet-aux
        ../../packages/fastapi
        ../../packages/fastapi-events
        ../../packages/fastapi-socketio
        ../../packages/starlette
        ../../packages/pytorch-lightning
        ../../packages/compel
        ../../packages/taming-transformers-rom1504
        ../../packages/albumentations
        ../../packages/qudida
        ../../packages/gfpgan
        ../../packages/basicsr
        ../../packages/facexlib
        ../../packages/realesrgan
        ../../packages/codeformer
        ../../packages/clipseg
        ../../packages/kornia
        ../../packages/picklescan
        ../../packages/diffusers
        ../../packages/pypatchmatch
        ../../packages/torch-fidelity
        ../../packages/resize-right
        ../../packages/torchdiffeq
        ../../packages/accelerate
        ../../packages/clip-anytorch
        ../../packages/clean-fid
        ../../packages/getpass-asterisk
        ../../packages/mediapipe
        ../../packages/python-engineio
      ])
      (final: prev: lib.mapAttrs
        (_: pkg: pkg.overrideAttrs (old: {
          nativeBuildInputs = old.nativeBuildInputs ++ [ final.pythonRelaxDepsHook ];
          pythonRemoveDeps = [ "opencv-python-headless" "opencv-python" "tb-nightly" "clip" ];
        }))
        {
          inherit (prev)
            albumentations
            qudida
            gfpgan
            basicsr
            facexlib
            realesrgan
            clipseg
          ;
        }
      )
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
