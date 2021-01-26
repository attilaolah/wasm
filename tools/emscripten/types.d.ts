// Additional Emscripten type declarations.

const { Emscripten, EmscriptenModule } = require("@types/emscripten");

// Global Module object, available to scripts in --pre-js and --post-js:
const Module: EmscriptenModule;

// Additional free functions that are not necessarily exported on the module object:
const {
    HEAPU8,
    _free,
    _malloc,
} = Emscripten;

// Additional functions missing from @types/emscripten:
declare function getNativeTypeSize(type: Emscripten.CType): number;
