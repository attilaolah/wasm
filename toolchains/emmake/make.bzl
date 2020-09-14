EMCONFIGURE = [
    "echo '/usr/lib/emscripten/emconfigure $(dirname $0)/configure $@' > emconfigure.sh",
    "chmod +x emconfigure.sh",
]

CONFIGURE_COMMAND = select({
    "//conditions:default": "configure",
    "//config:emscripten": "emconfigure.sh",
})

CONFIGURE_MAKE_COMMANDS = select({
    "//conditions:default": [
        "make",
        "make install",
    ],
    "//config:emscripten": [
        "emmake make",
        "emmake make install",
    ],
})

def emmake_make_commands(root):
    return [
        "emmake make -k -C $EXT_BUILD_ROOT/external/{}".format(root),
        "emmake make -C $EXT_BUILD_ROOT/external/{} install PREFIX=$INSTALLDIR".format(root),
    ]
