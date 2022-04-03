# Target EcmaScript 2021.
# ES2022 is not supported by closure-compiler yet.
ES = 2021

JS_TARGET = "ECMASCRIPT_{}".format(ES)
TS_TARGET = "es{}".format(ES)

IIFE_WRAP_ALL = """
echo -n "(() => {" > $@
cat $< >> $@
echo -n "})();" >> $@
"""

def iife(name, srcs):
    """Wraps all inputs in an IIFE."""
    native.genrule(
        name = name,
        srcs = srcs,
        outs = ["{}.js".format(name)],
        cmd = IIFE_WRAP_ALL,
    )
