FROM ubuntu:20.10
LABEL maintainer="Attila Oláh (atl@google.com)"

COPY [".", "/etc/"]
RUN ["sh", "/etc/update.sh"]

WORKDIR "/build"

CMD ["bash"]
