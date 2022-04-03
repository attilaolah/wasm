# Target EcmaScript 2021.
# ES2022 is not supported by closure-compiler yet.
ES = 2021

JS_TARGET = "ECMASCRIPT_{}".format(ES)
TS_TARGET = "es{}".format(ES)

IIFE_WRAP_ALL = """
echo -n "(() => {{" > $@
sed {replacements} $< >> $@
echo -n "}})();" >> $@
"""

def iife(name, srcs, replace = None):
    """Wraps all inputs in an IIFE."""
    native.genrule(
        name = name,
        srcs = srcs,
        outs = ["{}.js".format(name)],
        cmd = IIFE_WRAP_ALL.format(
            replacements = " ".join([
                '-e "s/{}/{}/g"'.format(src, dst)
                for src, dst in (replace or {}).items()
            ]),
        ),
    )
