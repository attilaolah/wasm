pushd "${BUILD_WORKSPACE_DIRECTORY}"

package_deps="$(mktemp)"

cat << EOF > "${package_deps}"
# AUTO-GENERATED FILE, DO NOT EDIT!
# To update it, run: bazel run //cmd:update_deps
PACKAGE_DEPS = [
EOF

bazel query 'filter("package", kind(bzl_library, //...))' \
  | awk '{print "    \"" $0 "\","}' \
  >> "${package_deps}"

echo "]" >> "${package_deps}"

mv "${package_deps}" "$(bazel info workspace)/lib/package_deps.bzl"

popd
