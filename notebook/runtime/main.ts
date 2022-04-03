function main(notebook: { ["root"]: HTMLElement }, layoutHTML: string) : void {
  mdToHTML(notebook.root, layoutHTML);
  populateTOC(notebook.root);
}

((
  // TypeScript: globals.
  Module: EmscriptenModule,
) : void => {
  Module["onRuntimeInitialized"] = () : void => {
    cmarkWrap();

    // Expose the "main" method via the module.
    Module["main"] = main;
  };
})(
  self["Module"] as EmscriptenModule,
);

