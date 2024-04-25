# TODO: this file is duplicate code from ./nixos/default.nix; deduplicate or figure something else out
{ lib
, stdenv
}:

## https://github.com/LoganBarnett/dotfiles/blob/eed1ad6c03283967320fb8bc04ed7b233b164f3b/nix/hacks/comfyui-services-web-apps/comfyui.nix#L281
let
  inherit (lib.trivial) throwIfNot;
  inherit (lib) isAttrs isString;
  inherit (lib.strings) concatStrings intersperse;
  inherit (lib.lists) flatten;
  inherit (lib.attrsets) attrValues mapAttrsToList;
  inherit (builtins) mapAttrs;
  # And here is ++leftPad++ sorry `join`.
  join = (sep: (xs: concatStrings (intersperse sep xs)));
  join-lines = join "\n";
  # We don't have a type system and this is pretty deep in the call stack,
  # so do some checking on the inputs so we have fewer stones to overturn
  # when something goes wrong later.
  throw-if-not-fetched = fetched:
    throwIfNot (isAttrs fetched) "fetched must be an attrset."
    throwIfNot (isString fetched.format) "fetched.format must be a string."
    throwIfNot (isString fetched.path) "fetched.path must be a string."
  ;
  fetched-to-symlink = path: name: fetched: (
    throwIfNot (isString path) "path must be a string."
    throwIfNot (isString name) "name must be a string."
    throw-if-not-fetched fetched
      ''
       ln -snf ${fetched.path} $out/${name}.${fetched.format}
      ''
  );

  # TODO: Should we submit this as a core/built-in function?
  # TODO: I think linkFarm or linkFarmFromDrvs will work.  See
  # https://github.com/NixOS/nixpkgs/blob/b43d3db76831cb80db01dd2ed50d66175fa2a325/pkgs/build-support/trivial-builders.nix#L475
  # and
  # https://github.com/NixOS/nixpkgs/blob/b43d3db76831cb80db01dd2ed50d66175fa2a325/pkgs/build-support/trivial-builders.nix#L503
  # - commits not specific intentionally.
  # In its current state, it is not suitable for a general purpose tool.
  # Right now `paths` is expected to be symlink statements, with the name
  # done a particular way.  More thought should be given as to how that is
  # to be made generic, or the parameter must be renamed and documented.
  # Perhaps the consumer should make intermediate derivations that capture
  # the name in its pure form?
  # Like joinSymlinks, creates a derivation whose assets are joined.
  # joinSymlinks doesn't support joining a derivation that is the asset
  # itself.  This handles the single-asset case only.  See
  # https://discourse.nixos.org/t/how-to-create-package-with-multiple-sources/9308/3
  # for how to handle packages with multiple assets.
  join-single-assets-symlinks = { name, linkCmds, ... }@args :
    stdenv.mkDerivation ({
      inherit name;
      pname = name;
      sourceRoot = name; # Is this required?
      # When using srcs, Nix doesn't know what to do with the fetched
      # values, erroring out with "do not know how to unpack source
      # archive <path>".  Instead we use installPhase to symlink the
      # assets under $out.
      # srcs = ...;
      installPhase = ''
        mkdir -p $out
      '' + (join-lines linkCmds);
      # No src/srcs, so don't do anything with them.
      phases = [ "installPhase" ];
    });

  # TODO: Make sure this comment still holds true.
  # Take all of the model files for the various model types defined in the
  # config of `models`, and translate it into a series of symlink shell
  # invocations.  The destination corresponds to the definitions in
  # `config-data`.
  # ex:
  #
  # linkModels
  #   {
  #     checkpoints = "/foo/checkpoints";
  #     vae = "/foo/vae";
  #   }
  #   {
  #     checkpoints = {
  #       sdxxl = fetchModel {
  #         url = "foo.com/sdxxl-v123";
  #         sha256 = "sha-string";
  #         format = "safetensors";
  #       };
  #     };
  #     vae = {
  #       fancy-vae = fetchModel {
  #         url = "foo.com/fancy-vae-v456";
  #         sha256 = "sha-string";
  #         # TODO: Use another format for example.
  #         format = "safetensors";
  #       };
  #     };
  #   }
  # Returns: ''
  # mkdir -p /foo/checkpoints
  # ln -s <sdxxl.drv> /foo/checkpoints/sdxxl.safetensors
  # mkdir -p /foo/vae
  # ln -s <fancy-vae.drv> /foo/vae/fancy-vae.safetensors
  # ''
  #
  linkModels = modelPaths: models:
    throwIfNot (isAttrs modelPaths) "modelPaths must be an attrset."
    # (throwIfNot (mapAttrs (_: v: isString v) modelPaths) "modelPaths must be an attrset of strings."
    (throwIfNot (isAttrs models) "models must be an attrset."
    (let
      # a typed derivation producing symlinks to models of a common type
      # fetched-by-name is an attrset of fetched models
      modelsDrvOfType = type: fetched-by-name: {
        model-type = type;
        drv = let
          name = "comfyui-models-${type}";
        in stdenv.mkDerivation {
          inherit name;
          pname = name;
          sourceRoot = name; # Is this required?
          # When using srcs, Nix doesn't know what to do with the fetched
          # values, erroring out with "do not know how to unpack source
          # archive <path>".  Instead we use installPhase to symlink the
          # assets under $out.
          # srcs = ...;
          installPhase = ''
            mkdir -p $out
          '' + (join-lines (mapAttrsToList (fetched-to-symlink modelPaths."${type}") fetched-by-name));
          # No src/srcs, so don't do anything with them.
          phases = [ "installPhase" ];
        };
      };
    in join-lines
      (builtins.map
        (x: ''
          subdir=${modelPaths."${x.model-type}"}
          mkdir -p $subdir
          ln -snf ${x.drv} $subdir/
        '')
        (flatten (mapAttrsToList modelsDrvOfType models))
      )
    ));
in models: let
    name = "comfyui-model-collection";
    modelPaths = mapAttrs (type: _: "$out/models/${type}") models;
  in stdenv.mkDerivation {
    inherit name;
    pname = name;
    sourceRoot = name;
    installPhase = ''
      mkdir -p $out
    '' + linkModels modelPaths models;
    phases = [ "installPhase" ];
  }

