{
  description = "neotern: neovim drawn as a native Tern surface";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system nixpkgs.legacyPackages.${system});

      mkNeotern = pkgs: pkgs.rustPlatform.buildRustPackage {
        pname = "neotern";
        version = "0.1.0-colors";

        src = ./.;

        cargoLock = {
          lockFile = ./Cargo.lock;
          # `tern-sdk` comes from git, so its output hash is pinned here.
          outputHashes."tern-sdk-0.1.0" = "sha256-q67rvUqXzGUgTHCdKCGYI5b4sua3qg0FlT/ZDGrbog8=";
        };

        # No upstream licence file, so no `meta.license`: claiming one would be a guess and would
        # gate `nix run` behind `allowUnfree`.
        meta = {
          description = "Neovim drawn as a native Tern surface, with cell colours mapped to Tern tokens";
          homepage = "https://github.com/arg3t/neotern";
          mainProgram = "neotern";
        };
      };
    in
    {
      packages = forAllSystems (system: pkgs: {
        neotern = mkNeotern pkgs;
        default = mkNeotern pkgs;
      });

      apps = forAllSystems (system: pkgs: {
        default = {
          type = "app";
          program = nixpkgs.lib.getExe self.packages.${system}.neotern;
        };
      });

      devShells = forAllSystems (system: pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.cargo
            pkgs.rustc
          ];
        };
      });
    };
}
