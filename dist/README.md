# NPM package bundle.

## 1. Bump the version number

- Edit `Cargo.toml`.
- Edit `package.json`.

Run the following to update the lockfiles:

```sh
CARGO_BAZEL_REPIN=true bazel sync --only=crate_index
npm install --package-lock-only
```

## 2. Commit changes

Commit the config files and the lockfiles in a separate commit, and merge the
changes via a pull request.

## Deploy to NPM

Deploy an optimised build to NPM.

```sh
bazel build -c opt //dist:pkg_tar
npm publish bazel-bin/dist/pkg_tar.tar
```
