# Zondax base stage
FROM alpine:3 AS zondax-base

# Certificate setup
RUN apk update && apk add --no-cache ca-certificates
COPY ./.docker/zondax_CA.crt /usr/local/share/ca-certificates/zondax_CA.crt
RUN update-ca-certificates

RUN apk add --no-cache libstdc++ libgcc

# Non-root user setup
RUN addgroup --system --gid 65532 zondax && \
    adduser --system --uid 65532 zondax
