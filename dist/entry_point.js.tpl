/*
 * Webpack entry point.
 *
 * This file simply lists the other files and the order in which they need to be bundled.
 */

// Bazel --compilation_mode (-c) flag.
const COMPILATION_MODE = "${COMPILATION_MODE}";

const CDN = "https://cdnjs.cloudflare.com/ajax/libs";

// TODO: Load from package-lock.json!
const PRISM_VERSION = "1.29.0";

// Loader comes first.
import { preload } from "../src/loader/loader.js";
preload(COMPILATION_MODE);

// Prevent Prism from firing automatically.
window["Prism"]["manual"] = true;
// Use CloudFlare CDN for the auto-loader path.
window["Prism"]["plugins"]["autoloader"]["languages_path"] = `${CDN}/prism/${PRISM_VERSION}/components/`;


// Remaining imports.
import "../external/npm/node_modules/prismjs/prism.js";
import "../external/npm/node_modules/prismjs/plugins/autoloader/prism-autoloader.js";
import * as wasm from "../src/runtime_bg.wasm";
export * from "../src/runtime_bg.js";

// Runtime.
wasm.__wbindgen_start();
