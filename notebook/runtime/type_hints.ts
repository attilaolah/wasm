// This file contains additional type declarations for the TypeScript compiler.
//
// This will not be included in the wasm_library() rule; only things that aid
// type checking should be added here.
const {
  HEAPU32,
  HEAPU64,
  Module,
  _free,
  _malloc,
} = require("@types/emscripten");

let getNativeTypeSize: (type: Emscripten.CType | "void*") => number;
