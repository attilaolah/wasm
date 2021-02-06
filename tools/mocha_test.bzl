"""Custom mocha_test() macro.

Among others, it allows passing in TypeScript source files.
"""

load("@npm//@bazel/typescript:index.bzl", "ts_library")
load("@npm//mocha:index.bzl", _mocha_test = "mocha_test")

def mocha_test(name, srcs, deps = None, args = None):
    """Wrapper around the mocha_test() rule from @npm//mocha.

    Allows passing in TypeScript source files. If there are any TypeScript
    files within the sources, a ts_library() rule is also created to convert
    those to JavaScript.

    Args:
      name: Name of the test rule.
      srcs: List of TypeScript (or JavaScript) source files.
      deps: JavaScript dependencies.
      args: Additional args to pass to the test runner.
    """
    if deps == None:
        deps = []
    if args == None:
        args = []

    ts_srcs = [src for src in srcs if src.endswith(".ts")]
    if ts_srcs:
        # Convert any TypeScript sources to JavaScript.
        ts_library(
            name = "{}_js".format(name),
            srcs = ts_srcs,
            deps = [
                "@npm//@types/mocha",
                "@npm//@types/node",
            ],
        )

    specs = [
        "{}/{}".format(native.package_name(), src)
        for src in srcs
    ]

    _mocha_test(
        name = name,
        args = specs + args + [
            "--color",
        ],
        data = srcs + deps,
    )
