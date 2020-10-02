"use strict";

const semver = /^\d+(\.\d+){0,2}$/;

// TODO: Use a real test framework!
function test() {
  const v = ccall("zlibVersion", "string", [], []);

  if (v.match(semver)) {
    console.log("PASS");
  } else {
    console.error(`Unexpected zlib version: "${v}".`);
    process.exitCode = 1;
  }
}
