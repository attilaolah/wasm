FROM insready/bazel:latest
LABEL maintainer="Attila Oláh (atl@google.com)"

COPY ["docker", "/etc/"]
RUN ["sh", "/etc/update.sh"]

WORKDIR "/build"

CMD ["bash"]
