// This file contains additional type declarations for the TypeScript compiler.
const {
  Module,
  _free,
  _malloc,
} = require("@types/emscripten");

let getNativeTypeSize: (type: Emscripten.CType | "void*") => number;
