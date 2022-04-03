// This could be done using a type-import:
//const { Module, _malloc, _free } = require("@types/emscripten"); // DELETEME
//
// However, that would result in double-declarations since Module is already
// declared before this code, and _malloc and _free will be declared below.

const _Module = self["Module"] as EmscriptenModule;
const __malloc = self["_malloc"] as EmscriptenModule["_malloc"];
const __free = self["_free"] as EmscriptenModule["_free"];
