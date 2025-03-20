# Docker Bake HCL configuration file
# This file defines the build targets and configurations for Docker Buildx bake

variable "PLATFORMS" {
  default = "linux/amd64"
}

variable "EXTRA_TAGS" {
  default = ""
}

function "generate_tags" {
  params = [base_name]
  result = concat(
    ["${base_name}:latest"],
    [for tag in split(" ", EXTRA_TAGS) : "${base_name}:${tag}" if tag != ""]
  )
}

# Default group that will be built when running 'docker buildx bake' without arguments
group "default" {
  targets = ["zup-make"]
}

# Final application target that combines artifacts from all builder stages
target "zup-make" {
  context    = "."
  dockerfile = ".docker/zup-make.Dockerfile"
  tags = generate_tags("zondax/zup-make")
}
