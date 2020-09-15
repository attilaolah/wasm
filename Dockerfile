FROM insready/bazel:latest
LABEL maintainer="Attila Oláh (atl@google.com)"

COPY ["update.sh", "/tmp"]
RUN ["sh", "/tmp/update.sh"]

WORKDIR "/build"

ENTRYPOINT ["bazel", "build", "//lib/..."]
