"""Workspace rule for downloading subpackage dependencies."""

load("//tools/python:package.bzl", "download_python")

def download_tools():
    """Download all tools sources."""
    download_python()
