"""Workspace rule for downloading subpackage dependencies."""

load("//tools/emscripten:package.bzl", "download_emscripten")
load("//tools/llvm:package.bzl", "download_llvm")
load("//tools/python:package.bzl", "download_python")

def download_tools():
    """Download all tools sources."""
    download_emscripten()
    download_llvm()
    download_python()
