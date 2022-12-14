console.log("Hello, WebPack!");

console.log("Trying to import ../toedi_wasm.js:");
//import("../toedi_wasm.js").catch(console.error);


import * as foo from "../toedi_wasm.js";
console.log(foo);
