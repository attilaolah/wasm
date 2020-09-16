FROM insready/bazel:latest
LABEL maintainer="Attila Oláh (atl@google.com)"

COPY ["docker", "/etc/"]
RUN ["sh", "/etc/update.sh"]

WORKDIR "/build"

ENV EM_CONFIG="/etc/emscripten_config.py" EM_CACHE="/tmp/emscripten"

ENTRYPOINT ["bazel", "build", "//lib/..."]
