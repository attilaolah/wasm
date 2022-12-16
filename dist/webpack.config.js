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
};
