load("@npm//mocha:index.bzl", _mocha_test = "mocha_test")

def mocha_test(name, srcs, deps = None, args = None):
    if deps == None:
        deps = []
    if args == None:
        args = []

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
