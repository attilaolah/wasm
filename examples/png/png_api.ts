/*
 * JavaScript API for pnglib.
 *
 * Wraps the native C functions in a more idiomatic JavaScript interface.
 */

// Wrapped functions.
// Start with $ to avoid clashing with the generated _ versions.
let $png_access_version_number: () => number;

let version: string;


Module["onRuntimeInitialized"] = () => {
  wrapFunctions();
  initGlobals();
  exportAPI();
};

function wrapFunctions() {
  $png_access_version_number = cwrap("png_access_version_number", "number", []);
}

function initGlobals() {
  const v = $png_access_version_number();
  version = [
    Math.floor(v/100/100),
    Math.floor(v/100%100),
    Math.floor(v%100),
  ].join(".");
}

function exportAPI() {
  Module["version"] = version;
}
