FROM insready/bazel:latest
LABEL maintainer="Attila Oláh (atl@google.com)"

COPY [".", "/etc/"]
RUN ["sh", "/etc/update.sh"]

WORKDIR "/build"

CMD ["bash"]
