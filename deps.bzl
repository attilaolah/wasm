"""External dependencies.

Macros defined in this file should be called near the end of the WORKSPACE
file, once the workspace dependencies have been set up.
"""

load("//lib:package.bzl", "download_lib")
load("//tools:package.bzl", "download_tools")

def external_dependencies():
    """Fetch and set up dependencies."""
    download_lib()
    download_tools()
