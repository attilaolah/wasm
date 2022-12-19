const CopyPlugin = require("copy-webpack-plugin");
const path = require("path");

const parentDir = path.dirname(__dirname);

module.exports = {
  entry: {
    style: [
      path.resolve(parentDir, process.env.NODE_PATH + "/normalize.css/normalize.css"),
      path.resolve(parentDir, "src/style/style.css"),
    ]
  },
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
        { from: "src/style/style.css.map", to: "style.css.map" },
        { from: "src/template.html", to: "template.html" },
      ],
    }),
  ],
};
