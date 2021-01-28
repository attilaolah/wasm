const assert = require("assert");

// Z requires Blob to be available as a global constructor.
global.Blob = require("cross-blob");

const Z = require("./z");

describe("compress", () => {
  const src = new Blob([
    "Hello, World! ",
    "This is some example text to be compressed.",
  ]);
  const big = new Blob([
    // Approx. 6.9 MB (6,888,891 bytes):
    JSON.stringify(Array.from(Array(1000000).keys())),
  ]);

  it("should compress a short string", async function() {
    const z = await Z();

    const buf = await src.arrayBuffer();
    const result = z.compress(new Uint8Array(buf));

    assert.equal(result.size, 63);
    assert.equal(result.type, "application/zlib");
  });

  it("should compress a somewhat larger (~6MB) string", async function() {
    const z = await Z();

    const buf = await big.arrayBuffer();
    const result = z.compress(new Uint8Array(buf));

    assert.equal(result.size, 2114878);
    assert.equal(result.type, "application/zlib");
  });
});

describe("version", () => {
  it("should return the version string", async function() {
    const z = await Z();

    assert.equal(z.version, "1.2.11");
  });
});
