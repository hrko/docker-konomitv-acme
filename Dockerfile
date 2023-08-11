FROM golang:1.21 AS supervisord-builder

# install xz-utils
RUN apt-get update && apt-get install -y xz-utils && rm -rf /var/lib/apt/lists/*

# install upx
RUN curl -L https://github.com/upx/upx/releases/download/v4.1.0/upx-4.1.0-amd64_linux.tar.xz | \
    tar -xJv --strip-components=1

# build supervisord
RUN git clone https://github.com/ochinchina/supervisord.git \
    && cd supervisord \
    && env GOOS=linux go build -tags release -a -ldflags "-s -w -linkmode external -extldflags -static" -o /supervisord \
    && ../upx --lzma /supervisord

# ----------------------------------------------------------------------------- #

FROM ghcr.io/hrko/konomitv-lite:v0.7.1-0

# Install supervisord
COPY --from=supervisord-builder /supervisord /usr/local/bin/supervisord
COPY supervisord.conf /etc/supervisord.conf

# Install lego
COPY --from=goacme/lego:latest /lego /usr/local/bin/lego

# Set default environment variables for lego
ENV LEGO_PATH=/cert/.lego \
    LEGO_SERVER=https://acme-v02.api.letsencrypt.org/directory \
    CERT_RENEWAL_TIME=5:00

# Install some scripts
COPY cert.sh cert-install.sh konomitv.sh /

# Change ENTRYPOINT
ENTRYPOINT ["/usr/local/bin/supervisord", "-c", "/etc/supervisord.conf"]
