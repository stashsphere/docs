{
  description = "Stashsphere Documentation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    stashsphere-backend.url = "github:stashsphere/backend";
  };

  outputs =
    inputs@{ flake-parts, stashsphere-backend, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem =
        { config
        , pkgs
        , system
        , ...
        }:
        let
          inherit (pkgs) python3Packages;
          stashsphere-openapi = stashsphere-backend.packages.${system}.default.doc;
        in
        {
          packages = {
            default = config.packages.html;
            html = python3Packages.callPackage ./nix/package.nix {
              inherit python3Packages;
              inherit stashsphere-openapi;
            };
          };

          apps = {
            default = config.apps.serve-docs;
            serve-docs = {
              type = "app";
              program = builtins.toString (
                pkgs.writeShellScript "serve-docs" ''
                  exec ${pkgs.python3}/bin/python3 -m http.server \
                      --bind 127.0.0.1 \
                      --directory ${config.packages.html}
                ''
              );
            };
          };

          checks = {
            pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
              src = ./.;
              hooks = {
                cspell = {
                  enable = true;
                  entry = "${pkgs.nodePackages.cspell}/bin/cspell --words-only";
                  types = [ "markdown" ];
                };
                markdownlint.enable = true;
                nixpkgs-fmt.enable = true;
                statix.enable = true;
              };
              settings.markdownlint.config = {
                MD013 = {
                  code_block_line_length = 120;
                };
              };
            };
          };

          devShells.default = pkgs.mkShell {
            inputsFrom = [ config.packages.html ];
            shellHook = ''
              ${config.checks.pre-commit-check.shellHook}
              [ ! -f docs/assets/openapi.json ]] && cp ${stashsphere-openapi}/openapi.json docs/assets/openapi.json
            '';
          };
        };
    };
}
