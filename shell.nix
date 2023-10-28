with import <nixpkgs> {};
clangStdenv.mkDerivation {
  name = "clang-nix-shell";
  buildInputs = [];
}
