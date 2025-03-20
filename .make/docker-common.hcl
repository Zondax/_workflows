# Common Docker Bake HCL variables and functions for reuse

variable "PLATFORMS" {
  default = "linux/amd64"
}

variable "EXTRA_TAGS" {
  default = ""
}

variable "BUILD_DATE" {
  default = "${timestamp()}"
}

variable "VERSION" {
  default = "latest"
}

# SBOM and Provenance configuration
variable "SBOM_FORMAT" {
  default = "spdx+json"
}

function "generate_tags" {
  params = [base_name]
  result = concat(
    ["${base_name}:latest"],
    [for tag in split(" ", EXTRA_TAGS) : "${base_name}:${tag}" if tag != ""]
  )
}

# Default target configuration with SBOM and provenance
target "common" {
  attest = [
    "type=sbom",
    "type=provenance,mode=max"
  ]
  platforms = ["${PLATFORMS}"]
  args = {
    BUILD_DATE = "${BUILD_DATE}"
    VERSION = "${VERSION}"
  }
}
