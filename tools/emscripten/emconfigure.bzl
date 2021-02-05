# These are in a separate file so that EMCONFIGURE would not have any external dependencies.
# This is to avoid cylcic dependencies since EMCONFIGURE is used to patch repos before loading them.

EMCONFIGURE = [
    "echo '\"${EMSCRIPTEN}/emconfigure\" $(dirname $0)/configure $@' >> emconfigure.sh",
    "chmod +x emconfigure.sh",
]
