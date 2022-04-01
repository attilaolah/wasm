LIBRARY_KEYS = {
    "z": "zlib",
}

INCLUDE_DIR_KEYS = dict(LIBRARY_KEYS.items() + {
    "png": "png_png",
}.items())

def library_key(dep):
    return "{}_library".format(LIBRARY_KEYS.get(dep, dep))

def include_dir_key(dep):
    return "{}_include_dir".format(INCLUDE_DIR_KEYS.get(dep, dep))
