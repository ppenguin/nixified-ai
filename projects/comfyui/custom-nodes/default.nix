{ lib
, stdenv
, python3Packages
, fetchFromGitHub
, unzip
, models
}@args:

let
  # Patches don't apply to $src, and as with many scripting languages that don't
  # have a build output per se, we just want the script source itself placed
  # into $out.  So just copy everything into $out instead of from $src so we can
  # make sure we get everything in the future, and we use the patched versions.
  install = ''
    shopt -s dotglob
    shopt -s extglob
    cp -r ./!($out|$src) $out/
  '';
  mkComfyUICustomNodes = args: stdenv.mkDerivation ({
    installPhase = ''
      runHook preInstall
      mkdir -p $out/
      ${install}
      runHook postInstall
    '';

    passthru.dependencies = { pkgs = []; models = {}; };
  } // args);
in {
  # https://github.com/Fannovel16/comfyui_controlnet_aux
  # Nodes for providing ControlNet hint images.
  controlnet-aux = mkComfyUICustomNodes {
    pname = "comfyui-controlnet-aux";
    version = "unstable-2024-04-05";
    pyproject = true;
    passthru.dependencies.pkgs = with python3Packages; [
      addict
      albumentations
      einops
      filelock
      ftfy
      fvcore
      importlib-metadata
      matplotlib
      mediapipe
      numpy
      omegaconf
      onnxruntime
      opencv4
      pillow
      python-dateutil
      pyyaml
      scikit-image
      scikit-learn
      scipy
      svglib
      torchvision
      trimesh
      yacs
      yapf
    ];
    src = fetchFromGitHub {
      owner = "Fannovel16";
      repo = "comfyui_controlnet_aux";
      rev = "c0b33402d9cfdc01c4e0984c26e5aadfae948e05";
      hash = "sha256-D9nzyE+lr6EJ+9Egabu+th++g9ZR05wTg0KSRUBaAZE=";
      fetchSubmodules = true;
    };
  };

  # https://github.com/Acly/comfyui-inpaint-nodes
  # Provides nodes for doing better inpainting.
  inpaint-nodes = mkComfyUICustomNodes {
    pname = "comfyui-inpaint-nodes";
    version = "unstable-2024-04-08";
    pyproject = true;
    src = fetchFromGitHub {
      owner = "Acly";
      repo = "comfyui-inpaint-nodes";
      rev = "8469f5531116475abb6d7e9c04720d0a29485a66";
      hash = "sha256-Ane8zA9BN9QlRcQOwji4hZF2xoDPe/GvSqEyAPR+T28=";
      fetchSubmodules = true;
    };
  };

  # https://github.com/cubiq/ComfyUI_IPAdapter_plus
  # This allows use of IP-Adapter models (IP meaning Image Prompt in this
  # context).  IP-Adapter models can out-perform fine tuned models
  # (checkpoints?).
  ipadapter-plus = mkComfyUICustomNodes {
    pname = "comfyui-ipadapter-plus";
    version = "unstable-2024-04-10";
    pyproject = true;
    src = fetchFromGitHub {
      owner = "cubiq";
      repo = "ComfyUI_IPAdapter_plus";
      rev = "417d806e7a2153c98613e86407c1941b2b348e88";
      hash = "sha256-yuZWc2PsgMRCFSLTqniZDqZxevNt2/na7agKm7Xhy7Y=";
      fetchSubmodules = true;
    };

    passthru.dependencies = {
      pkgs = with python3Packages; [
        insightface
        onnxruntime
      ];
      models = {
        insightface = { inherit (models.insightface) inswapper_128; };
        "insightface/models" = {
          buffalo_l = let
            name = "buffalo_l";
            url = "https://github.com/deepinsight/insightface/releases/download/v0.7/buffalo_l.zip";
          in stdenv.mkDerivation {
            inherit name;
            buildInputs = [ unzip ];
            phases = [ "installPhase" ];
            installPhase = ''
              mkdir -p $out
              unzip $src -d $out/
            '';
            src = import <nix/fetchurl.nix> {
              inherit name url;
              hash = "sha256-gP/jfYpZQNWac4TCAaKjjUdB8vPFHu9G67KCGKewyi8=";
            };
          };
        };
      };
    };
  };

  # https://github.com/Acly/comfyui-tooling-nodes
  # Make ComfyUI more friendly towards API usage.
  tooling-nodes = mkComfyUICustomNodes {
    pname = "comfyui-tooling-nodes";
    version = "unstable-2024-03-04";
    pyproject = true;
    src = fetchFromGitHub {
      owner = "Acly";
      repo = "comfyui-tooling-nodes";
      rev = "bcb591c7b998e13f12e2d47ee08cf8af8f791e50";
      hash = "sha256-dXeDABzu0bhMDN/ryHac78oTyEBCmM/rxCIPfr99ol0=";
      fetchSubmodules = true;
    };
  };

  # Handle upscaling of smaller images into larger ones.  This is helpful to go
  # from a prototyped image to a highly detailed, high resolution version.
  ultimate-sd-upscale = mkComfyUICustomNodes {
    pname = "ultimate-sd-upscale";
    version = "unstable-2024-03-30";
    src = fetchFromGitHub {
      owner = "ssitu";
      repo = "ComfyUI_UltimateSDUpscale";
      rev = "b303386bd363df16ad6706a13b3b47a1c2a1ea49";
      hash = "sha256-kcvhafXzwZ817y+8LKzOkGR3Y3QBB7Nupefya6s/HF4=";
      fetchSubmodules = true;
    };
  };

  ## Broken due to runtime mischief
  # https://github.com/Gourieff/comfyui-reactor-node
  # Fast and simple face swap node(s).
  reactor-node = (mkComfyUICustomNodes {
    pname = "comfyui-reactor-node";
    version = "unstable-2024-04-07";
    pyproject = true;
    passthru.dependencies = {
      pkgs = with python3Packages; [
        insightface
        onnxruntime
      ];
      models = {
        # expects these directories to exist:
        #   models/reactor/faces
        #   models/facerestore_models
        #   models/ultralytics/bbox
        #   models/ultralytics/segm
        #   models/sams
        # but it also seems to want arbitrary write-access to the models dir......

        insightface = { inherit (models.insightface) inswapper_128; };
        facerestore_models = {
          inherit (models.facerestore_models)
            "GFPGANv1.3"
            "GFPGANv1.4"
            "codeformer-v0.1.0"
            GPEN-BFR-512;
        };
      };
    };

    src = fetchFromGitHub {
      owner = "Gourieff";
      repo = "comfyui-reactor-node";
      rev = "05bf228e623c8d7aa5a33d3a6f3103a990cfe09d";
      hash = "sha256-2IrpOp7N2GR1zA4jgMewAp3PwTLLZa1r8D+/uxI8yzw=";
      fetchSubmodules = true;
    };

    meta.broken = true;
  });
}

