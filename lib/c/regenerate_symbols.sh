#!/usr/bin/env bash

# Shell script for manually rebuilding the Gnu C library symbol tables.
#
# This should be run from a clean Docker container that is not re-used.

if [ -z "${BUILD_WORKSPACE_DIRECTORY}" ]; then
  BUILD_WORKSPACE_DIRECTORY="$(bazel info workspace)"
fi

VERSION="$(python3 -c "$(cat "${BUILD_WORKSPACE_DIRECTORY}/lib/c/package.bzl"; echo "print(VERSION)")")"

TEMPDIR=/tmp/glibc
SRC="${TEMPDIR}/src"
BUILD="${TEMPDIR}/build"
INSTALL="${TEMPDIR}/install"

if [[ ! -f "${INSTALL}/lib/libc.a" ]]; then
  mkdir -p "${TEMPDIR}" "${SRC}" "${BUILD}" "${INSTALL}"

  apt-get --yes install build-essential python3 gawk bison wget jq 2>&1

  if [ ! -f "${TEMPDIR}/glibc-${VERSION}.tar.xz" ]; then
    wget "https://ftp.gnu.org/gnu/libc/glibc-${VERSION}.tar.xz" \
      -O "${TEMPDIR}/glibc-${VERSION}.tar.xz"
    tar --extract --directory="${SRC}" --strip-components=1 \
      -f "${TEMPDIR}/glibc-${VERSION}.tar.xz"
  fi

  pushd "${BUILD}"
  "${SRC}/configure" \
    --enable-static-nss=no \
    --enable-static-pie=yes \
    --prefix="${INSTALL}"
  make
  make install
  popd
fi

# First pass, without externs:
rm "${BUILD_WORKSPACE_DIRECTORY}"/lib/c/symbols/*.json
for archive in "${INSTALL}"/lib/*.a; do
  if [[ "$(basename "${archive}")" == "libm.a" ]]; then
    continue
  fi
  "${ARCHIVE_SYMBOLS}" \
    -nm "${NM}" \
    -archive "${archive}" \
    -output "${BUILD_WORKSPACE_DIRECTORY}/lib/c/symbols/$(basename "${archive}" .a).json"
done

# Second pass, using all externs:
echo "#!/usr/bin/env bash" > "${TEMPDIR}/regen.sh"
for archive in "${INSTALL}"/lib/*.a; do
  if [[ "$(basename "${archive}")" == "libm.a" ]]; then
    continue
  fi
  echo "${ARCHIVE_SYMBOLS}" \
    -nm "${NM}" \
    -archive "${archive}" \
    "$(
      ls -1 \
	"${BUILD_WORKSPACE_DIRECTORY}"/lib/c/symbols/*.json \
	"${BUILD_WORKSPACE_DIRECTORY}"/lib/gcc/symbols/*.json \
        | grep -v "${archive}" \
	| awk '{print "-externs " $0}' \
	| tr '\n' ' '\
    )" \
    -output "${BUILD_WORKSPACE_DIRECTORY}/lib/c/symbols/$(basename "${archive}" .a).json" \
    >> "${TEMPDIR}/regen.sh"
done
source "${TEMPDIR}/regen.sh"

# Pretty-print, remove unnecessary fields:
for result in "${BUILD_WORKSPACE_DIRECTORY}"/lib/c/symbols/*.json; do
  jq "{name: .name, symbols: ([.symbols[].name] | unique), externs: .externs, undefs: .undefs}" \
    < "${result}" > "${result}.pp"
  mv "${result}.pp" "${result}"
done

# Special-case libm which is an ld script:
mv "${BUILD_WORKSPACE_DIRECTORY}/lib/c/symbols/libm-${VERSION}.json" \
   "${BUILD_WORKSPACE_DIRECTORY}/lib/c/symbols/libm.json"
sed -e "s/libm-${VERSION}/libm/g" \
  -i "${BUILD_WORKSPACE_DIRECTORY}"/lib/c/symbols/*.json
