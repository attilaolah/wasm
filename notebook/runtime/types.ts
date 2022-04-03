// This could be done using a type-import:
//const { Module, _malloc, _free } = require("@types/emscripten"); // DELETEME
//
// However, that would result in double-declarations since Module is already
// declared before this code, and _malloc and _free will be declared below.
//
// So instead, declare a global EMSCRIPTEN accessor, and use it to access any
// "local" objects and functions. This will then be removed in post-processing.

// Module accessor.
// Post-processing removes the "EMSCRIPTEN_" prefix.
let EMSCRIPTEN_Module: EmscriptenModule;

// Globals accessor.
// Post-processing removes the "EMSCRIPTEN." prefix.
let EMSCRIPTEN: EmscriptenModule;
