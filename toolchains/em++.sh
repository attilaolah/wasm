#!/usr/bin/env bash

# Run the actual emar file in the correct location.
"${EXT_BUILD_DEPS}/bin/emscripten/$(basename $0 .sh)" $@
