CACHE_ENTRIES = {
    "CMAKE_AR": "/usr/lib/emscripten/emar",
    "CMAKE_C_FLAGS": "-fno-stack-protector",
    "CMAKE_CXX_FLAGS": "-fno-stack-protector",
    "CMAKE_STATIC_LINKER_FLAGS": "",
    "CMAKE_SHARED_LINKER_FLAGS": "",
    "CMAKE_EXE_LINKER_FLAGS": "",
}

def make_commands(root):
    return select({
        "//conditions:default": [
            "make -k -C $EXT_BUILD_ROOT/external/{}".format(root),
            "make -C $EXT_BUILD_ROOT/external/{} install PREFIX=$INSTALLDIR".format(root)
        ],
        "//config:emscripten": [
            "emmake make -k -C $EXT_BUILD_ROOT/external/{}".format(root),
            "emmake make -C $EXT_BUILD_ROOT/external/{} install PREFIX=$INSTALLDIR".format(root)
        ],
    })

def emcmake_cache_entries(original):
    return dict(original.items() + CACHE_ENTRIES.items())
