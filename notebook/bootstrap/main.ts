const { Module, _malloc, _free } = require("@types/emscripten"); // DELETEME

function bootstrap(root: HTMLElement, layoutHTML: string) : void {
  mdToHTML(root, layoutHTML);
  populateTOC(root);
}

Module["onRuntimeInitialized"] = () : void => {
  Module["bootstrap"] = bootstrap;
  cmarkWrap();
};
