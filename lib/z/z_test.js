describe('zlibVersion()', () => {
  const assert = require('assert');
  const zlibVersion = cwrap('zlibVersion', 'string', []);

  it('should return the version string', () => {
    assert.equal(zlibVersion(), '1.2.11');
  });
});
