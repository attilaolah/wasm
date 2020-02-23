CACHE_ENTRIES = {
    "CMAKE_AR": "/usr/lib/emscripten/emar",
    "CMAKE_C_FLAGS": "-fno-stack-protector",
    "CMAKE_CXX_FLAGS": "-fno-stack-protector",
    "CMAKE_STATIC_LINKER_FLAGS": "",
    "CMAKE_SHARED_LINKER_FLAGS": "",
    "CMAKE_EXE_LINKER_FLAGS": "",
}

def emcmake_cache_entries(original):
    return dict(original.items() + CACHE_ENTRIES.items())
