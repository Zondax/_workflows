# Docker Bake HCL configuration file
# This file defines the build targets and configurations for Docker Buildx bake

# Default group that will be built when running 'docker buildx bake' without arguments
group "default" {
  targets = ["zup-make"]
}

# Final application target that combines artifacts from all builder stages
target "zup-make" {
  inherits = ["docker-common"]
  context    = "."
  dockerfile = ".docker-private/zup-make.Dockerfile"
  tags = generate_tags("zondax/zup-make")
  platforms = ["linux/amd64", "linux/arm64"]
  attest = [
    "type=sbom",
    "type=provenance,mode=max,builder-id=github-actions"
  ]
}
