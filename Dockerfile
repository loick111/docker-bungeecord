FROM openjdk:8u131-jre-alpine

VOLUME ["/server", "/plugins", "/config"]
WORKDIR /server

ENV BUNGEE_HOME=/server
ENV BUNGEE_BASE_URL=https://ci.md-5.net/job/BungeeCord
ENV MEMORY=512m

RUN apk --no-cache add curl bash gettext

RUN addgroup -g 1000 -S bungeecord \
	&& adduser -u 1000 -D -S -G bungeecord bungeecord

ENV TIMEOUT=30000
ENV LOG_COMMANDS=false
ENV ONLINE_MODE=true
ENV PORT=25577
ENV GLOBAL_MOTD='&1BungeeCord Server'
ENV MAX_PLAYERS=20
ENV FORCE_DEFAULT_SERVER=false
ENV FORGE_SUPPORT=false
ENV INJECT_COMMANDS=false

ENV SRV1_NAME='lobby'
ENV SRV1_ADDRESS='localhost:25565'
ENV SRV1_MOTD='&1Lobby'

COPY config.yml.tmpl /

EXPOSE 25577
COPY entrypoint.sh /
CMD [ "bash", "/entrypoint.sh" ]