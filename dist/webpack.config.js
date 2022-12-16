const CopyPlugin = require("copy-webpack-plugin");

module.exports = {
  output: {
    asyncChunks: false,
    filename: "[name].js",
    module: true,
  },
  experiments: {
    futureDefaults: true,
    outputModule: true,
  },
  module: {
    rules: [
      {
        test: /\.wasm$/,
        type: "webassembly/async",
      },
    ],
  },
  plugins: [
    new CopyPlugin({
      patterns: [
        { from: "style/style.css", to: "style.css" },
        { from: "style/style.css.map", to: "style.css.map" },
        { from: "template.html", to: "template.html" },
      ],
    }),
  ],
};
