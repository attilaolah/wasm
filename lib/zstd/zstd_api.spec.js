const assert = require("assert");

const ZSTD = require("./zstd");

describe("version", () => {
  it("should return the version string", async function() {
    const zstd = await ZSTD();

    assert.equal(zstd.version, "1.4.4");
  });
});
