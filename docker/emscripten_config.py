import os.path
import shutil


def llvm_root():
    clang = shutil.which('clang')
    while clang and os.path.islink(clang):
        clang = os.path.join(os.path.dirname(clang), os.readlink(clang))
        clang = os.path.normpath(clang)
    return os.path.dirname(clang)


def node_js():
    return shutil.which('node') or shutil.which('nodejs')


LLVM_ROOT = llvm_root()
NODE_JS = node_js()
