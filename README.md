# _workflows

This repository contains reusable GitHub Actions workflows for standardizing CI/CD across Zondax projects.

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
