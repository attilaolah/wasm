const path = require("path");
//const WasmPackPlugin = require("@wasm-tool/wasm-pack-plugin");

module.exports = {
  mode: "production",
  output: {
    filename: "[name].js",
  },
  experiments: {
    futureDefaults: true,
  },
  //plugins: [
  //  new WasmPackPlugin({
  //    crateDirectory: __dirname,
  //  }),
  //],
    module: {
        rules: [
            {
                test: /\.wasm$/,
                //type: "asset/inline",
                type: "webassembly/async",
            },
        ],
    },
  devServer: {
    hot: false,
    liveReload: false,
    watchFiles: [],
  },
};
