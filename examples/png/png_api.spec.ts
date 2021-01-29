const assert = require("assert");

const PNG = require("./png");

describe("version", () => {
  it("should return the version string", async function() {
    const png = await PNG();

    assert.equal(png.version, "1.6.37");
  });
});
