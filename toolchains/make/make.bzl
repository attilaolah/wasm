EMCONFIGURE = [
    "echo 'emconfigure $(dirname $0)/configure $@' > emconfigure.sh",
    "chmod +x emconfigure.sh",
]

CONFIGURE_COMMAND = select({
    "//conditions:default": "configure",
    "//target:wasm": "emconfigure.sh",
})

CONFIGURE_MAKE_COMMANDS = select({
    "//conditions:default": [
        "make",
        "make install",
    ],
    "//target:wasm": [
        "emmake make",
        "emmake make install",
    ],
})

def emmake_make_commands(root):
    return [
        "emmake make -k -C $EXT_BUILD_ROOT/external/{}".format(root),
        "emmake make -C $EXT_BUILD_ROOT/external/{} install PREFIX=$INSTALLDIR".format(root),
    ]
