{ pkgs ? import ./nixpkgs.nix { } }:

pkgs.clangStdenv.mkDerivation {
  name = "clang-nix-shell";
  buildInputs = [
    pkgs.pkg-config
    pkgs.openssl
    pkgs.zlib
  ];
}
