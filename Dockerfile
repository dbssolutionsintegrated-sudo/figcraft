# figcraft-server, packaged from the upstream release binary instead of a Rust
# build, so a deploy takes seconds and never compiles on the host.
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
 && /usr/local/bin/figcraft-server --help >/dev/null 2>&1 || true

FROM gcr.io/distroless/cc-debian12:nonroot
COPY --from=fetch /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=fetch /usr/local/bin/figcraft-server /usr/local/bin/figcraft-server
USER nonroot
VOLUME /data
EXPOSE 47900
STOPSIGNAL SIGTERM
ENTRYPOINT ["/usr/local/bin/figcraft-server", "--listen", "0.0.0.0:47900", "--data", "/data"]
