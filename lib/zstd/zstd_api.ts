/*
 * JavaScript API for zstdlib.
 *
 * Wraps the native C functions in a more idiomatic JavaScript interface.
 */

// Wrapped functions.
// Start with $ to avoid clashing with the generated _ versions.
let $ZSTD_versionString: () => string;

let version: string;

Module["onRuntimeInitialized"] = () => {
  wrapFunctions();
  initGlobals();
  exportAPI();
};

function wrapFunctions() {
  $ZSTD_versionString = cwrap("ZSTD_versionString", "string", []);
}

function initGlobals() {
  version = $ZSTD_versionString();
}

function exportAPI() {
  Module["version"] = version;
}
