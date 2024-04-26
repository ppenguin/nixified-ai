{ ... }:
{
  perSystem = { pkgs, comfyuiCfg, comfyuiModels, ... }: let
    models = comfyuiCfg.models;
    installModels = pkgs.callPackage ../projects/comfyui/install-models.nix {};
  in {
    checks.modelInstallation = installModels {
      configs = { inherit (comfyuiModels.configs) controlnet-v1_1_fe-sd15-tile; };
    };
  };
}
