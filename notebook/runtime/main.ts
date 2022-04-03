const { Module, _malloc, _free } = require("@types/emscripten"); // DELETEME

function main(notebook: { ["root"]: HTMLElement }, layoutHTML: string) : void {
  mdToHTML(notebook.root, layoutHTML);
  populateTOC(notebook.root);
}

Module["onRuntimeInitialized"] = () : void => {
  Module["main"] = main;
  cmarkWrap();
};
