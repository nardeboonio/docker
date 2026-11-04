# syntax=docker/dockerfile:1
#
# Nardeboon in a container: the node (nardeboond) and its CLI (nardeboon),
# installed from Nardeboon's signed apt repository when the image is built.
# NB_VERSION picks a version; empty, the latest stable one.

FROM debian:stable-slim

ARG NB_VERSION=

LABEL org.opencontainers.image.title="Nardeboon" \
      org.opencontainers.image.description="Nardeboon, a mesh VPN for networks that block VPNs: the node and its CLI." \
      org.opencontainers.image.url="https://nardeboon.io" \
      org.opencontainers.image.documentation="https://nardeboon.io/docs" \
      org.opencontainers.image.source="https://github.com/nardeboonio/docker" \
      org.opencontainers.image.vendor="Nardeboon"

# The repository's key comes with this repository, so the build trusts
# nothing it fetches: apt checks every package against it.
COPY nardeboon.gpg /usr/share/keyrings/nardeboon.gpg
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates nftables; \
    echo "deb [signed-by=/usr/share/keyrings/nardeboon.gpg] https://pkgs.nardeboon.io/deb stable main" \
        > /etc/apt/sources.list.d/nardeboon.list; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "nardeboon${NB_VERSION:+=$NB_VERSION}"; \
    rm -rf /var/lib/apt/lists/*; \
    nardeboon version

COPY --chmod=0755 entrypoint.sh /usr/local/bin/nardeboon-entrypoint

# The node's keys and settings: keep them in a volume, or it joins again,
# as a new device, every time the container is made anew.
VOLUME /var/lib/nardeboon

HEALTHCHECK --interval=30s --timeout=10s --start-period=90s \
    CMD nardeboon status --json | grep -q '"state": *"running"'

ENTRYPOINT ["/usr/local/bin/nardeboon-entrypoint"]
