FROM ubuntu:21.04
LABEL maintainer="Attila Oláh (atl@google.com)"

COPY [".", "/etc/"]
RUN ["sh", "/etc/update.sh"]

WORKDIR "/build"

CMD ["bash"]
