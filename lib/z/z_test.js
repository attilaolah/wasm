describe('zlibVersion()', () => {
  let assert = require('assert');

  const version = '1.2.11';

  it(`should return ${version}`, () => {
    assert.equal(ccall('zlibVersion', 'string', [], []), version);
  });
});
