{ pkgs ? import <nixpkgs> { } }:
# Local build of this checkout, so the patch can be tried in Tern before it is pushed anywhere.
#   nix build -f ~/Workspaces/_fork/neotern/build.nix --no-link --print-out-paths
pkgs.rustPlatform.buildRustPackage {
  pname = "neotern";
  version = "0.1.0-colors";

  src = pkgs.lib.cleanSourceWith {
    src = ./.;
    filter = path: type: !(builtins.elem (baseNameOf path) [ "target" ".git" ]);
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes."tern-sdk-0.1.0" = "sha256-q67rvUqXzGUgTHCdKCGYI5b4sua3qg0FlT/ZDGrbog8=";
  };

  meta.mainProgram = "neotern";
}
