# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains **reusable GitHub Actions workflows** for standardizing CI/CD across Zondax projects. It provides centralized workflow templates that other Zondax repositories can reference to ensure consistent build, test, and deployment processes.

## Workflow Architecture

All workflows follow the `workflow_call` pattern with extensive input parameters for customization. Key workflows include:

- **Language-specific**: `_checks-ts.yaml`, `_checks-golang.yaml`, `_checks-rs.yaml`, `_checks-expo.yaml`
- **Infrastructure**: `_checks-infra.yaml`, `_checks-playwright.yaml`, `_cloud-run-deploy.yml`
- **Publishing**: `_publish-npm.yaml`, `_publish-docker.yaml`, `_publish-docker-bake.yaml`
- **Utilities**: `_post-pr-comment-reusable.yml`, `_pulumi-wif.yaml`, `_atlas-migrations-reusable.yml`

## Development Commands

### Common Make Targets (used in workflows)
- `make go-build` - Build Go applications
- `make go-test` - Run Go tests
- `make go-coverage` - Generate Go coverage reports
- `make go-lint-install && make go-lint` - Install and run Go linter
- `make go-mod-check` - Verify Go module dependencies
- `make docker-info` - Display Docker build information
- `make docker-publish` - Publish Docker images

### Package Management
- **Default package manager**: `bun` (version 1.2.13)
- **Alternative**: `pnpm` (latest)
- **Node.js version**: 22 (configurable)
- **Go version**: 1.24

### Testing and Coverage
- **Coverage threshold**: 75% (configurable)
- **Coverage commands**: `test:coverage` (for TypeScript/Node.js)
- **Rust testing**: Uses `cargo-tarpaulin` for coverage
- **Playwright**: Supports sharding and custom browsers

## Key Configuration Patterns

### Workflow Usage Pattern
```yaml
jobs:
  typescript-checks:
    uses: zondax/_workflows/.github/workflows/_checks-ts.yaml@main
    with:
      node_version: '18'
      enable_linting: true
      coverage_threshold: 80
```

### Security Features
- **GitHub App authentication** for private repository access
- **Workload Identity Federation (WIF)** for GCP authentication
- **Custom CA certificates** in `.docker/zondax_CA.crt`
- **Private Go modules** support via GOPRIVATE configuration

### Container Strategy
- **Base image**: `ubuntu:24.04` (configurable)
- **Custom base**: `zondax-base.Dockerfile` (Alpine with CA certificates)
- **Ubuntu dev base**: `ubuntu-22.04-dev.Dockerfile` (Ubuntu with dev tools)
- **Non-root user**: uid/gid 65532
- **Runners**: Uses custom `zondax-runners`

## Base Images

This repository provides pre-built base images for Zondax projects, published to Docker Hub.

### Available Images

| Image | Description | Tools Included |
|-------|-------------|----------------|
| `zondax/ubuntu-ci:22.04` | Ubuntu 22.04 CI base | build-essential, git, curl, wget, make, jq, pkg-config, node, pnpm, rust, playwright |
| `zondax/ubuntu-ci:24.04` | Ubuntu 24.04 CI base | build-essential, git, curl, wget, make, jq, pkg-config, node, pnpm, rust, playwright |

### Local Development

```bash
# Build all base images locally
make bake-load

# List available bake targets
make bake-list

# Test the image
docker run --rm -it zondax/ubuntu-ci:22.04 bash

# Build with custom tag
docker buildx bake -f .docker/docker-bake.hcl --set "*.tags=myapp:test" --load
```

### Publishing

Base images are automatically published:
- **Nightly at 2 AM UTC** - picks up upstream security updates
- **On push to main** - when `.docker/**` files change
- **Manual** - via workflow_dispatch

## Docker Bake Publishing

The `_publish-docker-bake.yaml` workflow provides Docker publishing using `docker buildx bake`.

### Features

- **No Makefile required** - uses `docker buildx bake` directly
- **Repo-defined tagging** - consumer repos define tags in `docker-bake.hcl`
- **Multi-registry** - Docker Hub and/or GCP Artifact Registry
- **Security** - Cosign signing, SLSA provenance, optional SBOM
- **Caching** - Registry-backed cache when configured by the bake file
- **Multi-arch** - Optional QEMU-based arm64 builds

### Contract Boundary

`_publish-docker-bake.yaml` is an orchestration workflow, not an image-definition workflow.

Consumer repositories are expected to define explicitly in their own `docker-bake.hcl` and Dockerfiles:

- image tag strategy
- OCI labels
- build args used by the image or application

In particular, repo-specific metadata conventions such as `VERSION`, `BUILD_VERSION`, `BUILD_COMMIT`, and `BUILD_DATE` should remain repo-defined rather than being auto-injected by the shared workflow.

### Usage in Consuming Repos

1. Create a `docker-bake.hcl` in your repo:

```hcl
target "default" {
  dockerfile = "Dockerfile"
  context    = "."
}
```

2. Reference the workflow:

```yaml
jobs:
  publish:
    uses: zondax/_workflows/.github/workflows/_publish-docker-bake.yaml@main
    with:
      bake_file: docker-bake.hcl
    secrets:
      DOCKERHUB_USER: ${{ secrets.DOCKERHUB_USER }}
      DOCKERHUB_TOKEN: ${{ secrets.DOCKERHUB_TOKEN }}
```

### Multi-Variant Builds

Define multiple targets in your `docker-bake.hcl`:

```hcl
group "default" {
  targets = ["alpine", "debian"]
}

target "alpine" {
  dockerfile = "Dockerfile"
  args       = { BASE_IMAGE = "alpine:3.20" }
  tags       = ["zondax/myapp:alpine"]
}

target "debian" {
  dockerfile = "Dockerfile"
  args       = { BASE_IMAGE = "debian:bookworm-slim" }
  tags       = ["zondax/myapp:latest"]
}
```

Then build specific targets:

```yaml
with:
  image_name: zondax/myapp
  bake_targets: "alpine,debian"
```

### GCP Artifact Registry

```yaml
jobs:
  publish:
    uses: zondax/_workflows/.github/workflows/_publish-docker-bake.yaml@main
    with:
      registry: gcp-ar
      environment: production
```

### Workflow Inputs

| Input | Default | Description |
|-------|---------|-------------|
| `image_name` | required | Image name (e.g., `zondax/myapp`) |
| `registry` | `dockerhub` | Target: `dockerhub`, `gcp-ar`, or `both` |
| `bake_file` | `docker-bake.hcl` | Path to bake file |
| `bake_targets` | `""` | Comma-separated targets (empty = default) |
| `platforms` | `linux/amd64` | Target platforms |
| `enable_multiarch` | `false` | Enable QEMU for arm64 |
| `enable_signing` | `true` | Cosign keyless signing |
| `enable_provenance` | `true` | SLSA provenance |
| `enable_sbom` | `false` | Generate SBOM |

## Environment Management

### Timeout Configuration
- **Default timeout**: 10 minutes for all workflows
- **Configurable per workflow** via inputs

### Environment Variables
- `.build/.env` contains build metadata (git hash, branch, build dates)
- Support for multiple environments via workflow inputs
- **Codecov integration** for coverage visualization

## Architecture Notes

### Workflow Inputs
All workflows accept extensive customization through inputs:
- Enable/disable specific checks (linting, testing, coverage)
- Version specifications (Node.js, Go, Rust, package managers)
- Coverage thresholds and reporting options
- Authentication and access control settings

### Multi-language Support
- **TypeScript/Node.js**: Full testing, linting, coverage pipeline
- **Go**: Build, test, lint, coverage with module verification
- **Rust**: Clippy linting, testing, security audit with cargo-audit
- **React Native/Expo**: Specialized mobile development checks

### Deployment Capabilities
- **Google Cloud Run** with multi-container support
- **Cloudflare R2** for asset releases
- **NPM registry** publishing with semantic versioning
- **Docker registry** publishing with multi-architecture support
