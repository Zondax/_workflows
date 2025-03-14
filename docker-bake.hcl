# Docker Bake HCL configuration file
# This file defines the build targets and configurations for Docker Buildx bake

# We should pass IMAGE_TAGS and use the name of the image in the docker-bake.hcl file
variable "DOCKER_IMAGE_NAME" {
  default = "zondax/zup-make"
}

variable "PLATFORMS" {
  default = "linux/amd64"
}

# Default group that will be built when running 'docker buildx bake' without arguments
group "default" {
  targets = ["zup-make"]
}

# Final application target that combines artifacts from all builder stages
target "zup-make" {
  context    = "."
  dockerfile = ".docker/zup-make.Dockerfile"
}
