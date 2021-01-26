/*
 * JavaScript API for lz4lib.
 *
 * Wraps the native C functions in a more idiomatic JavaScript interface.
 */

// Wrapped functions.
// Start with $ to avoid clashing with the generated _ versions.
let $LZ4_versionString: () => string;

let version: string;


Module["onRuntimeInitialized"] = () => {
  wrapFunctions();
  initGlobals();
  exportAPI();
};

function wrapFunctions() {
  $LZ4_versionString = cwrap("LZ4_versionString", "string", []);
}

function initGlobals() {
  version = $LZ4_versionString();
}

function exportAPI() {
  Module["version"] = version;
}
