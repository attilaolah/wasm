version_specs=(${VERSION_SPECS})

echo "Updating ${PACKAGE_BZL}:"

cd "${BUILD_WORKSPACE_DIRECTORY}"
for spec in ${version_specs[@]}; do
  up_to_date=$("${JQ}" -r '.up_to_date // false' < "${spec}")
  "${JQ}" . < "${spec}"
  if [ "${up_to_date}" == "true" ]; then
    continue
  fi

  version="$("${JQ}" -r .version < "${spec}")"
  upstream_version="$("${JQ}" -r .upstream_version < "${spec}")"
  url="$("${JQ}" -r .urls[0] < "${spec}")"
  url="$(sed "s/${version}/${upstream_version}/g" <<< "${url}")"
  tmp="$(mktemp)"

  curl "${url}" --output "${tmp}" --silent

  checksum="$(sha256sum "${tmp}" | awk '{ print $1 }')"

  sed -i "${PACKAGE_BZL}" \
    -e "s/VERSION = \"${version}\"/VERSION = \"${upstream_version}\"/"
  sed -i "${PACKAGE_BZL}" \
    -e "s/SHA256 = \".*\"/SHA256 = \"${checksum}\"/"
done

echo "Done!"
