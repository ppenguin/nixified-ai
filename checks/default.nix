{ ... }:
{
  perSystem = { pkgs, system, comfyuiCfg, comfyuiModels, ... }: let
    models = comfyuiCfg.models;
    allModels = comfyuiModels;
    installModels = pkgs.callPackage ../projects/comfyui/install-models.nix {};
  in {
    checks.modelInstallation = installModels {
      configs = { inherit (allModels.configs) controlnet-v1_1_fe-sd15-tile; };
    };
  };
}
