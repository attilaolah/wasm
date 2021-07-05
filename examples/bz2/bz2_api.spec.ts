const assert = require("assert");

const BZ2 = require("./bz2");

describe("version", () => {
  it("should return the version string", async function() {
    const bz2 = await BZ2();

    assert.equal(bz2.version, "1.0.8");
  });
});
