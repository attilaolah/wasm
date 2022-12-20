/*
 * Webpack entry point.
 *
 * This file simply lists the other files and the order in which they need to be bundled.
 */

// Loader comes first.
import { preload } from "../src/loader.js";
preload();

// Prevent Prism from firing automatically.
window["Prism"].manual = true;

// Remaining imports.
import "../external/npm/node_modules/prismjs/prism.js";
import * as wasm from "./runtime_wasm_bg.wasm";
export * from "./runtime_wasm_bg.js";

// Runtime.
wasm.__wbindgen_start();
