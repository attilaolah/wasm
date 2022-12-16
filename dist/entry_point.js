/*
 * Webpack entry point.
 *
 * This file simply lists the other files and the order in which they need to be bundled.
 */

import { preload } from "../src/loader.js";
preload();

import * as wasm from "./runtime_wasm_bg.wasm";
export * from "./runtime_wasm_bg.js";
wasm.__wbindgen_start();
