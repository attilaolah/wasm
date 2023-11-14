with import <nixpkgs> {};
(mkShell.override { stdenv = llvmPackages_16.stdenv; }) {
  buildInputs = [
    pkg-config
    openssl
    zlib
  ];
}
