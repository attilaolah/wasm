describe('Z', () => {
  const assert = require('assert');

  describe('zlibVersion()', () => {
    const zlibVersion = cwrap('zlibVersion', 'string', []);

    it('should return the version string', () => {
      assert.equal(zlibVersion(), '1.2.11');
    });
  });

  describe('zlibCompileFlags()', () => {
    const zlibCompileFlags = cwrap('zlibCompileFlags', 'number', []);

    it('should return the compile-time flags', () => {
      assert.equal(zlibCompileFlags(), 149);
    });
  });

  describe('compressBound()', () => {
    const compressBound = cwrap('compressBound', 'number', ['number']);

    it('should return the upper bound on the compressed size', () => {
      assert.equal(compressBound(0), 13);
      assert.equal(compressBound(64), 77);
      assert.equal(compressBound(1024), 1037);
      assert.equal(compressBound(1024*1024*1024), 1074069549);
    });
  });

  describe('compress', () => {
    const compress = cwrap('compress', 'number', ['number', 'number', 'number', 'number']);
    const compressBound = cwrap('compressBound', 'number', ['number']);
    const zlibCompileFlags = cwrap('zlibCompileFlags', 'number', []);

    // <zlib.h>
    const Z_OK = 0;

    const lipsum = 'Lorem Ipsum...';
    const srcLen = lengthBytesUTF8(lipsum);

    // Type sizes, as document ed in zlib.h,
    // in the documentation of zlibCompileFlags().
    const sizeInBits = {
      0b00: 16,
      0b01: 32,
      0b10: 64,
      0b11: 0, // 'other'
    };
    const bitsPerByte = 8;

    it('should compress lorem-ipsum', () => {
      const flags = zlibCompileFlags();
      const bound = compressBound(srcLen);

      const uLongSize = sizeInBits[(flags & (0b11 << 2)) >> 2];

      const src = _malloc(srcLen+1);
      const dst = _malloc(bound);
      const dstLen = _malloc(uLongSize / bitsPerByte);

      stringToUTF8(lipsum, src, srcLen+1);
      setValue(dstLen, bound, `i${uLongSize}`);

      const statusCode = compress(dst, dstLen, src, srcLen);
      const statusStr = {
        '0': 'Z_OK',
        '-4': 'Z_MEM_ERROR',
        '-5': 'Z_BUF_ERROR',
      }[statusCode] || 'UNKNOWN';
      const compressedLen = getValue(dstLen, `i${uLongSize}`);

      const result = Buffer.from(
        new Uint8Array(HEAPU8.subarray(dst, dst + compressedLen)));

      _free(dstLen);
      _free(dst);
      _free(src);

      assert.equal(statusStr, 'Z_OK');
      assert.equal(compressedLen, 22);

      // python -c '
      //   import base64, zlib
      //   print(base64.b64encode(zlib.compress(b"Lorem Ipsum...")).decode("ascii"))
      // '
      assert.equal(
        result.toString('base64'),
        'eJzzyS9KzVXwLCguzdXT0wMAJgUEuA==');
    });
  });
});
