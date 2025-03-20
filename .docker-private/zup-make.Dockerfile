# Base image for creating an empty OCI image
FROM scratch
LABEL org.opencontainers.image.description="Zondax reusable .make"
LABEL maintainer="Zondax <hello@zondax.ch>"

# Supply chain attestation labels
LABEL org.opencontainers.image.source="https://github.com/zondax/.workflows"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.vendor="Zondax"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.version="${VERSION}"

# Create non-root user and group
# Note: Since this is a scratch image, we need to handle this differently
# The user/group should be created in the binary itself or through the build process
USER 65532:65532

# Copy binary with proper permissions
COPY --chown=65532:65532 .make .make
