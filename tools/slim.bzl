# TODO: Convert to a rule!
def slim_library(name, srcs, **kwargs):
    cmd = [
        "LANG=en_US.UTF-8",
        'GEM_PATH="external/bundle/lib/ruby/3.1.0"',
        "$(rootpath @bundle//:bin/slimrb)",
        '"$(rootpath {}.slim)"'.format(name),
        ">$@",
    ]

    native.genrule(
        name = name,
        srcs = srcs + [
            "@bundle//:bin/slimrb",
        ],
        outs = [name + ".html"],
        cmd = select({
            "//cond:clang_opt": " ".join(cmd),
            "//conditions:default": " ".join(cmd + ["--pretty"]),
        }),
        **kwargs
    )
