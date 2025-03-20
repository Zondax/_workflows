# Zondax base stage
FROM alpine:3 AS zondax-base

# Certificate setup
RUN apk update && apk add --no-cache ca-certificates
COPY ./zondax_CA.crt /usr/local/share/ca-certificates/zondax_CA.crt
RUN update-ca-certificates

RUN apk add --no-cache libstdc++ libgcc

# Non-root user setup
RUN addgroup --system --gid 1001 zondax && \
    adduser --system --uid 1001 zondax
