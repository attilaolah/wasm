function main(notebook: { ["root"]: HTMLElement }, layoutHTML: string) : void {
  mdToHTML(notebook.root, layoutHTML);
  populateTOC(notebook.root);
}

EMSCRIPTEN_Module["onRuntimeInitialized"] = () : void => {
  cmarkWrap();

  // Expose the "main" method via the module.
  EMSCRIPTEN_Module["main"] = main;
};
