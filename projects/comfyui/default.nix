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

    models = import ./models { inherit (pkgs) fetchurl; inherit lib; };

    # we require a python3 with an appropriately overriden package set depending on GPU
    mkComfyUIVariant = python3: args:
      pkgs.callPackage ./package.nix ({ inherit python3; } // args);

    # everything here needs to be parametrised over gpu vendor
    legacyPkgs = vendor: let
      customNodes = import ./custom-nodes {
        inherit lib models;
        inherit (pkgs) stdenv fetchFromGitHub;
        python3Packages = python3Variants."${vendor}";
      };
      plugins = { inherit models customNodes; };

      # withConfig ::
      #   (plugins
      #     -> (plugins //
      #       { basePath :: str
      #       , inputPath :: str
      #       , outputPath :: str
      #       , tempPath :: str
      #       , userPath :: str
      #       })
      #   ) -> drv
      # where
      #   plugins =
      #     { models :: attrsOf fetchedModels
      #     , customNodes :: attrsOf fetchedCustomNodes
      #     }
      #   `attrsOf fetchedModels` is the type of what is in ./models/default.nix,
      #   `attrsOf fetchedCustomNodes`, is the type of what is in ./custom-nodes/default.nix
      withConfig = f:
        mkComfyUIVariant python3Variants."${vendor}".python (f plugins);
      # withplugins :: (plugins -> plugins) -> drv
      # we can be a little explicit about the interface here
      withPlugins = f: withConfig (pgns: { inherit (f pgns) customNodes models; });

      # takes a list of model sets and merges them
      mergeModels = import ./models/merge-sets.nix;

      kritaModels = import ./models/krita-ai-plugin.nix models;
      kritaCustomNodes = import ./custom-nodes/krita-ai-plugin.nix customNodes;
      # There are reasons one might want to add more models, but extra custom nodes add
      # nothing to the krita plugin, so this takes a function over models only.
      kritaServerWithModels = f:
        withPlugins (_: {
          # if you want the full set (required + optional) plus some extra models,
          # you can do `kritaServerWithModels (ms: (import ./models/krita-ai-plugin.nix ms).optional)`
          models = mergeModels [ kritaModels.required (f models) ];
          customNodes = kritaCustomNodes;
        });
    in {
      inherit
        customNodes
        mergeModels
        models
        kritaModels
        kritaServerWithModels
        withConfig
        withPlugins;
    };

    amd = legacyPkgs "amd";
    nvidia = legacyPkgs "nvidia";
  in {
    legacyPackages.comfyui = { inherit amd nvidia; };

    packages = {
      krita-comfyui-server-amd = with amd; kritaServerWithModels (_: kritaModels.optional);
      krita-comfyui-server-amd-minimal = amd.kritaServerWithModels (_: {});
      krita-comfyui-server-nvidia = with nvidia; kritaServerWithModels (_: kritaModels.optional);
      krita-comfyui-server-nvidia-minimal = nvidia.kritaServerWithModels (_: {});
    };
  };
}
