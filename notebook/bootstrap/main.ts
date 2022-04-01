const { Module, _malloc, _free } = require("@types/emscripten"); // DELETEME

function bootstrap(root: HTMLElement) : void {
  mdToHTML(root);
}

Module["onRuntimeInitialized"] = () : void => {
  Module["bootstrap"] = bootstrap;
  cmarkWrap();
};

