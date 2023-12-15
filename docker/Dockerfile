FROM ubuntu:24.04
LABEL maintainer="Attila Oláh (attilaolah@gmail.com)"

ENV DEBIAN_FRONTEND="noninteractive"
RUN ["apt-get", "update"]
RUN ["apt-get", "--yes", "dist-upgrade"]
RUN ["apt-get", "--yes", "install", "ca-certificates", "nix"]

ADD "https://github.com/bazelbuild/bazelisk/releases/download/v1.19.0/bazelisk-linux-amd64" /usr/local/bin/bazel
RUN ["chmod", "+x", "/usr/local/bin/bazel"]

WORKDIR "/build"

CMD ["bash"]
