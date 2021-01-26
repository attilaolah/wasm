/*
 * JavaScript API for zlib.
 *
 * Wraps the native C functions in a more idiomatic JavaScript interface.
 */

// From <zlib.h>:
const Z_OK = 0;
const Z_MEM_ERROR = -4;
const Z_BUF_ERROR = -5;

// Wrapped functions.
// Start with $ to avoid clashing with the generated _ versions.
let $compress: (
  dest: number,
  destLen: number,
  source: number,
  sourceLen: number,
) => number;
let $compressBound: (sourceLen: number) => number;
let $zlibCompileFlags: () => number;
let $zlibVersion: () => string;

// Globals:
let uLongType: Emscripten.CIntType;
let uLongBytes: number;

let version: string;

class ZReturnError extends Error {
  constructor(code: number) {
    switch (code) {
      case Z_MEM_ERROR:
        super("Z: Z_MEM_ERROR error");
        break;
      case Z_BUF_ERROR:
        super("Z: Z_BUF_ERROR error");
        break;
      default:
        super("Z: UNKNOWN error");
    }
  }
}

class ZCompileFlagsError extends Error {
  constructor(flags: number) {
    super(`Z: zlibCompileFlags() returned unexpected value: ${flags}`);
  }
}

Module["onRuntimeInitialized"] = () => {
  wrapFunctions();
  initGlobals();
  exportAPI();
};

function wrapFunctions() {
  $compress = cwrap("compress", "number", ["number", "number", "number", "number"]);
  $compressBound = cwrap("compressBound", "number", ["number"]);
  $zlibCompileFlags = cwrap("zlibCompileFlags", "number", []);
  $zlibVersion = cwrap("zlibVersion", "string", []);
}

function initGlobals() {
  // Type sizes, as documented in <zlib.h>,
  // in the documentation of zlibCompileFlags().
  const flags = $zlibCompileFlags();
  switch ((flags & (0b11 << 2)) >> 2) {
    case 0b00:
      uLongType = "i16";
      break;
    case 0b01:
      uLongType = "i32";
      break;
    case 0b10:
      uLongType = "i64";
      break;
    default:
      throw new ZCompileFlagsError(flags);
  }

  uLongBytes = getNativeTypeSize(uLongType);
  version = $zlibVersion();
}

function exportAPI() {
  Module["compress"] = compress;
  Module["version"] = version;
}

function compress(data: Uint8Array): Blob {
  const bound = $compressBound(data.byteLength);
  
  const src = _malloc(data.byteLength);
  const dst = _malloc(bound);
  const dstLen = _malloc(uLongBytes);

  setValue(dstLen, bound, uLongType);
  HEAPU8.set(data, src);

  // Compress data & free the source buffer.
  const statusCode = $compress(dst, dstLen, src, data.byteLength);
  _free(src);

  if (statusCode != Z_OK) {
    _free(dstLen);
    _free(dst);
    throw new ZReturnError(statusCode);
  }

  // Calculate compressed size & free memory.
  const compressedLen = getValue(dstLen, uLongType);
  _free(dstLen);

  // Create a copy of the compressed array so we can free the temporary buffer.
  //const buffer = HEAPU8.subarray(dst, dst + compressedLen);
  const buffer = new Uint8Array(HEAPU8.subarray(dst, dst + compressedLen)).buffer;
  const result = new Blob([buffer], {type: "application/zlib"});
  //_free(dst);
  
  return result;
}
