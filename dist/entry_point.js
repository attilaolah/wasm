/*
 * Webpack entry point.
 *
 * This file simply lists the other files and the order in which they need to be bundled.
 */

// Loader comes first.
import { preload } from "../src/loader/loader.js";
preload();

// Prevent Prism from firing automatically.
window["Prism"].manual = true;

// Remaining imports.
import "../external/npm/node_modules/prismjs/prism.js";
import * as wasm from "../src/runtime_bg.wasm";
export * from "../src/runtime_bg.js";

// Runtime.
wasm.__wbindgen_start();
