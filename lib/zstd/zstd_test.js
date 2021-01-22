describe('ZSTD_versionString()', () => {
  const assert = require('assert');
  const versionString = cwrap('ZSTD_versionString', 'string', []);

  it('should return the version string', () => {
    assert.equal(versionString(), '1.4.4');
  });
});
