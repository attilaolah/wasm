const assert = require("assert");
const Blob = require("cross-blob");

const ZSTD = require("./zstd");

// ZSTD requires Blob to be available as a global constructor.
global.Blob = Blob;

describe("compress", () => {
  const src = new Blob([
    "Hello, World! ",
    "This is some example text to be compressed.",
  ]);
  const big = new Blob([
    JSON.stringify(Array.from(Array(1000000).keys())),
  ]);

  it("should compress a short string", async function() {
    const zstd = await ZSTD();

    const buf = await src.arrayBuffer();
    const result = zstd.compress(new Uint8Array(buf));

    assert.equal(result.size, 66);
    assert.equal(result.type, "application/zstd");
  });

  it("should compress a somewhat larger (~6MB) string", async function() {
    const zstd = await ZSTD();

    const buf = await big.arrayBuffer();
    const result = zstd.compress(new Uint8Array(buf));

    assert.equal(result.size, 251531);
    assert.equal(result.type, "application/zstd");
  });
});

describe("version", () => {
  it("should return the version string", async function() {
    const zstd = await ZSTD();

    assert.equal(zstd.version, "1.4.4");
  });
});
