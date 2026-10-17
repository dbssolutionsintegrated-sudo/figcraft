# figcraft-server, packaged from the upstream release binary instead of a Rust
# build, so a deploy takes seconds and never compiles on the host.
#
# The base is a normal Debian image (not distroless) because the container has
# to start as root long enough to take ownership of the /data volume, then drop
# to uid 65532 with setpriv. Distroless cannot, and without it the unprivileged
# user cannot write the volume the panel mounts.

FROM debian:bookworm-slim AS fetch
ARG TARGETARCH
ARG VERSION=0.6.0
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl \
 && case "$TARGETARCH" in \
      amd64) ARCH=x86_64 ;; \
      arm64) ARCH=aarch64 ;; \
      *) echo "unsupported arch: $TARGETARCH" >&2; exit 1 ;; \
    esac \
 && curl -fsSL "https://github.com/storytold/figcraft/releases/download/v${VERSION}/figcraft-server-${VERSION}-linux-${ARCH}.tar.gz" -o /tmp/s.tgz \
 && mkdir -p /out && tar -xzf /tmp/s.tgz -C /out \
 && BIN=$(find /out -type f -name 'figcraft-server*' | head -1) \
 && install -m 755 "$BIN" /usr/local/bin/figcraft-server \
 && /usr/local/bin/figcraft-server --version

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates util-linux \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /data && chown 65532:65532 /data
COPY --from=fetch /usr/local/bin/figcraft-server /usr/local/bin/figcraft-server
COPY deploy/entrypoint.sh /usr/local/bin/entrypoint
RUN chmod 755 /usr/local/bin/entrypoint
EXPOSE 47900
STOPSIGNAL SIGTERM
ENTRYPOINT ["/usr/local/bin/entrypoint"]
