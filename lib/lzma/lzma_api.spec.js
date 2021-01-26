const assert = require("assert");

const LZMA = require("./lzma");

describe("version", () => {
  it("should return the version string", async function() {
    const lzma = await LZMA();

    assert.equal(lzma.version, "5.2.5");
  });
});
