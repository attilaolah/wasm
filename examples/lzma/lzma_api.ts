/*
 * JavaScript API for lzmalib.
 *
 * Wraps the native C functions in a more idiomatic JavaScript interface.
 */

// Wrapped functions.
// Start with $ to avoid clashing with the generated _ versions.
let $lzma_version_string: () => string;

let version: string;


Module["onRuntimeInitialized"] = () => {
  wrapFunctions();
  initGlobals();
  exportAPI();
};

function wrapFunctions() {
  $lzma_version_string = cwrap("lzma_version_string", "string", []);
}

function initGlobals() {
  version = $lzma_version_string();
}

function exportAPI() {
  Module["version"] = version;
}
