import os.path


_EXT_BUILD_DEPS = os.getenv("EXT_BUILD_DEPS")

BINARYEN_ROOT = os.path.join(_EXT_BUILD_DEPS, "bin", "binaryen")
LLVM_ROOT = os.path.join(_EXT_BUILD_DEPS, "bin", "llvm", "bin")
NODE_JS = os.path.join(_EXT_BUILD_DEPS, "bin", "node", "bin", "node")

# Emscripten expects bynaryen under ${BINARYEN_ROOT}/bin, so create a symlink:
if not os.path.exists(os.path.join(BINARYEN_ROOT, "bin")):
    os.symlink(".", os.path.join(BINARYEN_ROOT, "bin"))

del _EXT_BUILD_DEPS
