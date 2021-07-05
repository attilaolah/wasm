/*
 * JavaScript API for bz2lib.
 *
 * Wraps the native C functions in a more idiomatic JavaScript interface.
 */

// Wrapped functions.
// Start with $ to avoid clashing with the generated _ versions.
let $BZ2_bzlibVersion: () => string;

let version: string;


Module["onRuntimeInitialized"] = () => {
  wrapFunctions();
  initGlobals();
  exportAPI();
};

function wrapFunctions() {
  $BZ2_bzlibVersion = cwrap("BZ2_bzlibVersion", "string", []);
}

function initGlobals() {
  // Remove the trailing ", DD-Mmm-YYYY" suffix.
  version = $BZ2_bzlibVersion().replace(/,.*/, "");
}

function exportAPI() {
  Module["version"] = version;
}
