{
  nixConfig = {
    extra-trusted-substituters = [
      "https://ai.cachix.org"
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://cuda-maintainers.cachix.org"
      "https://numtide.cachix.org"
    ];
    extra-substituters = [
      "https://ai.cachix.org"
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://cuda-maintainers.cachix.org"
      "https://numtide.cachix.org"
    ];
    extra-trusted-public-keys = [
      "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
    ];
  };

  description = "A Nix Flake that makes AI reproducible and easy to run";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    hercules-ci-effects = {
      url = "github:hercules-ci/hercules-ci-effects";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      flake-parts,
      hercules-ci-effects,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      perSystem = { system, ... }: let
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in {
        _module.args = { inherit pkgs; };
        legacyPackages = {
          koboldai = builtins.throw ''


                   koboldai has been dropped from nixified.ai due to lack of upstream development,
                   try textgen instead which is better maintained. If you would like to use the last
                   available version of koboldai with nixified.ai, then run:

                   nix run github:nixified.ai/flake/0c58f8cba3fb42c54f2a7bf9bd45ee4cbc9f2477#koboldai
          '';
        };
        formatter = pkgs.alejandra;
      };
      flake.templates = {
        comfyui = {
          path = ./templates/comfyui;
          description = "A basic ComfyUI configuration to get you started";
        };
      };
      imports = [
        ./flake-modules
        hercules-ci-effects.flakeModule
      ];
    };
}
