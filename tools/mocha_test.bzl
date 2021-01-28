load("@npm//@bazel/typescript:index.bzl", "ts_library")
load("@npm//mocha:index.bzl", _mocha_test = "mocha_test")

def mocha_test(name, srcs, deps = None, args = None):
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
                # Additional dependencies for the test runner:
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
