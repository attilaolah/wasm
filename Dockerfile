FROM insready/bazel:latest
LABEL maintainer="Attila Oláh (atl@google.com)"

COPY [".", "${HOME}/wasm"]
WORKDIR "${HOME}/wasm"

RUN ["sh", "update.sh"]

ENTRYPOINT ["bazel", "build", "//lib/..."]
