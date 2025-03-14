# .workflows

This repository contains reusable GitHub Actions workflows for standardizing CI/CD across Zondax projects.

## Usage

To use these workflows in your repository, reference them in your GitHub Actions workflow:

```yaml
jobs:
  typescript-checks:
    uses: zondax/.workflows/.github/workflows/checks-ts.yaml@main
    with:
      node_version: '18'  # optional
      disable_linting: false  # optional
      disable_tests: false  # optional
```

Each workflow accepts specific input parameters for customization. Check individual workflow files for available options.

## Available Workflows

### TypeScript (`checks-ts.yaml`)

- Linting and testing for TypeScript projects
- Configurable Node.js version
- Optional test and lint disabling

### Golang (`checks-golang.yaml`)

- Go-specific checks and tests
- Configurable package path and Go version
- Uses Zondax custom runners

### Expo (`checks-expo.yaml`)

- Specific checks for Expo/React Native projects

### Infrastructure (`checks-infra.yaml`)

- Infrastructure code validation

### Docker (`publish-docker.yaml`)

- Docker image building and publishing

### Pulumi (`pulumi-wif.yml`)

- Pulumi infrastructure deployment with WIF

### Zup (`zup.yaml`)

- Custom Zondax Updates
