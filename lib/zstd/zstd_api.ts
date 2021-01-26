/*
 * JavaScript API for zstdlib.
 *
 * Wraps the native C functions in a more idiomatic JavaScript interface.
 */

// Wrapped functions.
// Start with $ to avoid clashing with the generated _ versions.
let $ZSTD_compress: (
  dst: number,
  dstCapacity: number,
  src: number,
  srcSize: number,
  level: number,
) => number;
let $ZSTD_compressBound: (srcSize: number) => number;
let $ZSTD_getErrorName: (code: number) => string;
let $ZSTD_isError: (code: number) => boolean;
let $ZSTD_versionString: () => string;

let version: string;

Module["onRuntimeInitialized"] = () => {
  wrapFunctions();
  initGlobals();
  exportAPI();
};

function wrapFunctions() {
  $ZSTD_compress = cwrap("ZSTD_compress", "number", ["number", "number", "number", "number", "number"]);
  $ZSTD_compressBound = cwrap("ZSTD_compressBound", "number", ["number"]);
  $ZSTD_getErrorName = cwrap("ZSTD_getErrorName", "string", ["number"]);
  $ZSTD_isError = cwrap("ZSTD_isError", "boolean", ["number"]);
  $ZSTD_versionString = cwrap("ZSTD_versionString", "string", []);
}

function initGlobals() {
  version = $ZSTD_versionString();
}

function exportAPI() {
  Module["version"] = version;
  Module["compress"] = compress;
}

function compress(data: Uint8Array, level?: number): Blob {
  if (level === undefined) {
    // Special value 0 means use default compression level.
    level = 0;
  }

  const bound = $ZSTD_compressBound(data.byteLength);

  const src = _malloc(data.byteLength);
  const dst = _malloc(bound);

  HEAPU8.set(data, src);

  // Compress data & free the source buffer.
  const compressedSize = $ZSTD_compress(dst, bound, src, data.byteLength, level);
  _free(src);

  if ($ZSTD_isError(compressedSize)) {
    _free(dst);
    throw new Error("TODO: Throw proper error!");
  }

  // Create a copy of the compressed array so we can free the temporary buffer.
  //const buffer = HEAPU8.subarray(dst, dst + compressedLen);
  const buffer = new Uint8Array(HEAPU8.subarray(dst, dst + compressedSize)).buffer;
  const result = new Blob([buffer], {type: "application/zstd"});
  _free(dst);

  return result;
}
