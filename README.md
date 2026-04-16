# _workflows

This repository contains reusable GitHub Actions workflows for standardizing CI/CD across Zondax projects.

## Docker Publish Contract

The reusable Docker publish workflow, [`.github/workflows/_publish-docker-bake.yaml`](/Users/lenij/.codex/worktrees/57ea/_workflows/.github/workflows/_publish-docker-bake.yaml:1), is intentionally an orchestration layer.

Consumer repositories are responsible for defining image metadata explicitly in their own `docker-bake.hcl` files and Dockerfiles, including:

- image tags and tag strategy
- OCI labels
- build arguments consumed by the application or image build

The shared workflow is responsible for:

- checkout and registry authentication
- Buildx setup and execution
- push behavior
- signing, provenance, and SBOM options
- publishing outputs such as image digests

The shared workflow should not become the source of truth for repo-specific metadata conventions such as `BUILD_VERSION`, `BUILD_COMMIT`, or `BUILD_DATE`.

## Usage

To use these workflows in your repository, reference them in your GitHub Actions workflow:

```yaml
jobs:
  typescript-checks:
    uses: zondax/_workflows/.github/workflows/_checks-ts.yaml@main
    with:
      node_version: '18'  # optional
      disable_linting: false  # optional
      disable_tests: false  # optional
```

Each workflow accepts specific input parameters for customization. Check individual workflow files for available options.
Please review the workflow files for more information on the available options.
