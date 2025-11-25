# Docker Bake configuration for Zondax base images
#
# Local build:
#   docker buildx bake -f .docker/docker-bake.hcl
#
# Build specific target:
#   docker buildx bake -f .docker/docker-bake.hcl ubuntu-22-dev
#
# Build and load into local docker:
#   docker buildx bake -f .docker/docker-bake.hcl --load
#
# Build with custom tag:
#   docker buildx bake -f .docker/docker-bake.hcl --set "*.tags=mytest:local"

group "default" {
  targets = ["ubuntu-22-dev", "ubuntu-24-dev"]
}

# Common configuration inherited by all targets
target "_common" {
  context   = "."
  platforms = ["linux/amd64"]
  pull      = true # Always pull fresh base image for security updates
}

target "ubuntu-22-dev" {
  inherits   = ["_common"]
  dockerfile = ".docker/ubuntu-22.04-dev.Dockerfile"
  # Tags include version suffix - zondax ci tags will expand these
  tags       = ["zondax/ubuntu-dev:22.04"]
}

target "ubuntu-24-dev" {
  inherits   = ["_common"]
  dockerfile = ".docker/ubuntu-24.04-dev.Dockerfile"
  # Tags include version suffix - zondax ci tags will expand these
  tags       = ["zondax/ubuntu-dev:24.04"]
}

# Future base images can be added here:
#
# target "alpine-dev" {
#   inherits   = ["docker-metadata-action"]
#   dockerfile = ".docker/alpine-dev.Dockerfile"
#   context    = "."
#   platforms  = ["linux/amd64"]
#   pull       = true
# }
