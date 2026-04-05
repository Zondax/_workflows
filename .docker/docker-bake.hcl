# Docker Bake configuration for Zondax CI base images
#
# Local build:
#   docker buildx bake -f .docker/docker-bake.hcl
#
# Build specific target:
#   docker buildx bake -f .docker/docker-bake.hcl ubuntu-22-ci
#
# Build and load into local docker:
#   docker buildx bake -f .docker/docker-bake.hcl --load
#
# Build with custom tag:
#   docker buildx bake -f .docker/docker-bake.hcl --set "*.tags=mytest:local"

group "default" {
  targets = ["ubuntu-22-ci", "ubuntu-22-tauri", "ubuntu-24-ci", "ubuntu-24-tauri"]
}

# Common configuration inherited by all targets
target "_common" {
  context   = "."
  platforms = ["linux/amd64"]
  pull      = true # Always pull fresh base image for security updates
}

target "ubuntu-22-ci" {
  inherits   = ["_common"]
  dockerfile = ".docker/ubuntu-22.04-ci.Dockerfile"
  target     = "ubuntu-22-playwright"
  # Keep the generic tag as a compatibility alias while consumers migrate
  # to explicit workload tags.
  tags = [
    "zondax/ubuntu-ci:22.04",
    "zondax/ubuntu-ci:22.04-playwright",
  ]
  cache-from = ["type=registry,ref=zondax/ubuntu-ci:22.04-cache"]
  cache-to   = ["type=registry,ref=zondax/ubuntu-ci:22.04-cache,mode=max"]
}

target "ubuntu-22-tauri" {
  inherits   = ["_common"]
  dockerfile = ".docker/ubuntu-22.04-ci.Dockerfile"
  target     = "ubuntu-22-tauri"
  tags       = ["zondax/ubuntu-ci:22.04-tauri"]
  cache-from = ["type=registry,ref=zondax/ubuntu-ci:22.04-tauri-cache"]
  cache-to   = ["type=registry,ref=zondax/ubuntu-ci:22.04-tauri-cache,mode=max"]
}

target "ubuntu-24-ci" {
  inherits   = ["_common"]
  dockerfile = ".docker/ubuntu-24.04-ci.Dockerfile"
  target     = "ubuntu-24-playwright"
  # Keep the generic tag as a compatibility alias while consumers migrate
  # to explicit workload tags.
  tags = [
    "zondax/ubuntu-ci:24.04",
    "zondax/ubuntu-ci:24.04-playwright",
  ]
  cache-from = ["type=registry,ref=zondax/ubuntu-ci:24.04-cache"]
  cache-to   = ["type=registry,ref=zondax/ubuntu-ci:24.04-cache,mode=max"]
}

target "ubuntu-24-tauri" {
  inherits   = ["_common"]
  dockerfile = ".docker/ubuntu-24.04-ci.Dockerfile"
  target     = "ubuntu-24-tauri"
  tags       = ["zondax/ubuntu-ci:24.04-tauri"]
  cache-from = ["type=registry,ref=zondax/ubuntu-ci:24.04-tauri-cache"]
  cache-to   = ["type=registry,ref=zondax/ubuntu-ci:24.04-tauri-cache,mode=max"]
}

# Future base images can be added here:
#
# target "alpine-ci" {
#   inherits   = ["docker-metadata-action"]
#   dockerfile = ".docker/alpine-ci.Dockerfile"
#   context    = "."
#   platforms  = ["linux/amd64"]
#   pull       = true
# }
