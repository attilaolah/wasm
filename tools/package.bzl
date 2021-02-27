"""Workspace rule for downloading subpackage dependencies."""

load("//tools/emscripten:package.bzl", "download_emscripten")
load("//tools/llvm:package.bzl", "download_flang", "download_llvm")

def download_tools():
    """Download all tools sources."""
    download_emscripten()
    download_flang()
    download_llvm()
