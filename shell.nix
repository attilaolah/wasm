{ pkgs ? import ./nixpkgs.nix { } }:

pkgs.clang16Stdenv.mkDerivation {
  name = "clang-nix-shell";
  buildInputs = [
    pkgs.pkg-config
    pkgs.openssl
    pkgs.zlib
  ];
}
