# Common Docker Bake HCL variables and functions for reuse

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
