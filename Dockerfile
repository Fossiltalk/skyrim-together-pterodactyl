# Pterodactyl yolk for Skyrim Together Reborn, built on the official server image.
ARG ST_TAG=latest
FROM tiltedphoques/st-reborn-server:${ST_TAG} AS st

# Same base as upstream (Debian 12) so glibc/libstdc++ match the prebuilt binaries.
FROM debian:bookworm-slim
ARG ST_TAG
ARG ST_VERSION=unknown
ENV ST_VERSION=${ST_VERSION}
LABEL org.opencontainers.image.source="https://github.com/Fossiltalk/skyrim-together-pterodactyl" \
      org.opencontainers.image.description="Pterodactyl yolk for the Skyrim Together Reborn dedicated server (upstream tag: ${ST_TAG})" \
      org.opencontainers.image.licenses="MIT"

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates tini tzdata iproute2 \
 && rm -rf /var/lib/apt/lists/* \
 && useradd -m -d /home/container -s /bin/bash container

# Binaries stay in the image (read-only, always match the tag). The server resolves
# config/, Data/, logs/ and resources/ relative to its CWD, which is /home/container.
COPY --from=st /st-server/ /opt/stserver/
COPY entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh /opt/stserver/SkyrimTogetherServer

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container
STOPSIGNAL SIGINT
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
