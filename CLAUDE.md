# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains **reusable GitHub Actions workflows** for standardizing CI/CD across Zondax projects. It provides centralized workflow templates that other Zondax repositories can reference to ensure consistent build, test, and deployment processes.

## Workflow Architecture

All workflows follow the `workflow_call` pattern with extensive input parameters for customization. Key workflows include:

- **Language-specific**: `_checks-ts.yaml`, `_checks-golang.yaml`, `_checks-rs.yaml`, `_checks-expo.yaml`
- **Infrastructure**: `_checks-infra.yaml`, `_checks-playwright.yaml`, `_cloud-run-deploy.yml`
- **Publishing**: `_publish-npm.yaml`, `_publish-docker.yaml`
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
- **Non-root user**: uid/gid 65532
- **Runners**: Uses custom `zondax-runners`

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