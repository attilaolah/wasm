const assert = require("assert");

const LZ4 = require("./lz4");

describe("version", () => {
  it("should return the version string", async function() {
    const lz4 = await LZ4();

    assert.equal(lz4.version, "1.9.2");
  });
});
