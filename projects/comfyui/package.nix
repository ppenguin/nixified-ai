let
  defaultBasePath = "/var/lib/comfyui";
in
{ lib
, python3
, linkFarm
, writers
, writeTextFile
, fetchFromGitHub
, stdenv
, symlinkJoin
, models
, customNodes
, basePath ? defaultBasePath
, inputPath ? "${defaultBasePath}/input"
, outputPath ? "${defaultBasePath}/output"
, tempPath ? "${defaultBasePath}/temp"
, userPath ? "${defaultBasePath}/user"
}:

let
  mergeModels = import ./models/merge-sets.nix;

  # aggregate all custom nodes' dependencies
  dependencies = with builtins; lib.pipe customNodes [
    attrValues
    (map (v: v.dependencies))
    (foldl'
      ({ pkgs, models }: x: {
        pkgs = pkgs ++ (x.pkgs or []);
        models = mergeModels [ models (x.models or {}) ];
      })
      { pkgs = []; models = {}; })
  ];
  # create a derivation for our custom nodes
  customNodesDrv = linkFarm "comfyui-custom-nodes" customNodes;
  # create a derivation for our models
  modelsDrv = let
    inherit (lib.attrsets) concatMapAttrs;
    concatMapModels = f: concatMapAttrs (type: concatMapAttrs (f type));
    # create a flattened set from our nested model set;
    # attribute name is the file path to the model;
    # value is the store path of the fetched model.
    toNamePath = concatMapModels (type: _name: fetched: {
      "${type}/${fetched.name}" = fetched;
    });
  in linkFarm "comfyui-models" (toNamePath (mergeModels [ models dependencies.models ]));

  config-data = {
    comfyui = let
      modelsDir = "${modelsDrv}";
    in {
      base_path = basePath;
      checkpoints = "${modelsDir}/checkpoints";
      clip = "${modelsDir}/clip";
      clip_vision = "${modelsDir}/clip_vision";
      configs = "${modelsDir}/configs";
      controlnet = "${modelsDir}/controlnet";
      embeddings = "${modelsDir}/embeddings";
      inpaint = "${modelsDir}/inpaint";
      ipadapter = "${modelsDir}/ipadapter";
      loras = "${modelsDir}/loras";
      upscale_models= "${modelsDir}/upscale_models";
      vae = "${modelsDir}/vae";
      vae_approx = "${modelsDir}/vae_approx";
    };
  };

  modelPathsFile = writeTextFile {
    name = "extra_model_paths.yaml";
    text = (lib.generators.toYAML {} config-data);
  };

  pythonEnv = python3.withPackages (ps: with ps; [
    torch
    torchvision
    transformers
    safetensors
    accelerate
    torchsde
    aiohttp
    einops
    kornia
    pyyaml
    pillow
    scipy
    psutil
    tqdm
  ] ++ dependencies.pkgs);

  executable = writers.writeDashBin "comfyui" ''
    ${pythonEnv}/bin/python $out/comfyui \
      --input-directory ${inputPath} \
      --output-directory ${outputPath} \
      --extra-model-paths-config ${modelPathsFile} \
      --temp-directory ${tempPath} \
      "$@"
  '';
in stdenv.mkDerivation rec {
  pname = "comfyui";
  version = "unstable-2024-04-15";

  src = fetchFromGitHub {
    owner = "comfyanonymous";
    repo = "ComfyUI";
    rev = "45ec1cbe963055798765645c4f727122a7d3e35e";
    hash = "sha256-oK+PwAJdvItK1NaRRJMNI4Oh/g4jNt1M5gWfXEy3C9g=";
  };

  installPhase = ''
    runHook preInstall
    echo "Preparing bin folder"
    mkdir -p $out/bin/
    echo "Copying comfyui files"
    # These copies everything over but test/ci/github directories.  But it's not
    # very future-proof.  This can lead to errors such as "ModuleNotFoundError:
    # No module named 'app'" when new directories get added (which has happened
    # at least once).  Investigate if we can just copy everything.
    cp -r $src/comfy $out/
    cp -r $src/comfy_extras $out/
    cp -r $src/app $out/
    cp -r $src/web $out/
    cp -r $src/*.py $out/
    mv $out/main.py $out/comfyui
    echo "Copying ${modelPathsFile} to $out"
    cp ${modelPathsFile} $out/extra_model_paths.yaml
    echo "Setting up custom nodes"
    ln -snf ${customNodesDrv} $out/custom_nodes
    echo "Symlinking models into installation dir for scripts that are unaware of extra_model_paths.yaml"
    ln -snf ${modelsDrv} $out/models
    echo "Copying executable script"
    cp ${executable}/bin/comfyui $out/bin/comfyui
    substituteInPlace $out/bin/comfyui --replace "\$out" "$out"
    echo "Patching python code..."
    # TODO: Evaluate if we can get rid of this on the latest version - there
    # seems to be a lot more arguments available now.
    substituteInPlace $out/folder_paths.py --replace "if not os.path.exists(input_directory):" "if False:"
    substituteInPlace $out/folder_paths.py --replace 'os.path.join(os.path.dirname(os.path.realpath(__file__)), "user")' '"${userPath}"'
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/comfyanonymous/ComfyUI";
    description = "The most powerful and modular stable diffusion GUI with a graph/nodes interface.";
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}
