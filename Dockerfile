FROM docker:dind

RUN apk --update add bash curl jq && rm -rf /var/cache/apk/*

RUN mkdir /data
WORKDIR /data

COPY .bashrc /root/

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENV DOCKER_HOST=unix:///var/run/docker.sock
ENV CONFIG_FILE=wrapper-config.json

ENTRYPOINT /entrypoint.sh
