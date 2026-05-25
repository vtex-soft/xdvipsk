FROM ubuntu:24.04
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update && apt-get upgrade -y && apt-get install \
    build-essential \
    mingw-w64 \
    texinfo \
    git-all \
    mc \
    -y

COPY builder.sh /builder.sh
WORKDIR /usr/local/src
ENTRYPOINT ["/builder.sh"]
