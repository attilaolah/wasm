"""Emscripten config.

Loads all config values from environment variables with the "EM_" prefix.
"""
import os


CACHE = os.getenv('EM_CACHE')
BINARYEN_ROOT = os.getenv('EM_BINARYEN_ROOT')
LLVM_ROOT = os.getenv('EM_LLVM_ROOT')
NODE_JS = os.getenv('EM_NODE_JS')
