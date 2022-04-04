function main(notebook: { ["root"]: HTMLElement }, layoutHTML: string) : void {
  mdToHTML(notebook.root, layoutHTML);
  populateTOC(notebook.root);
}

Module["onRuntimeInitialized"] = () : void => {
  cmarkWrap();

  // Expose the "main" method via the module.
  Module["main"] = main;
};
