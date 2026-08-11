# _workflows

Reusable GitHub Actions workflows for standardizing CI/CD across Zondax projects.

## Pin policy

| Ref | Use when |
| --- | --- |
| **`@v11`** (current floating major) | **Preferred** for production consumers (e.g. Kunobi) |
| **`@vN.M.P`** or commit SHA | Hermetic / delayed upgrades |
| **`@main`** | Bleeding edge only — can break without a major bump |

When we cut a new major (`v12`, …), update consumer pins deliberately; do not assume `@main`.

## Node / package managers

| Item | Current house default |
| --- | --- |
| Node | **22** (publish-npm default) or **24** via `zondax/ubuntu-ci:24.04` images |
| Package managers | Detected from lockfile (`pnpm` / `bun` / yarn / npm); image includes pnpm + bun |
| **Node 18** | **EOL — do not use** |

## Usage

```yaml
jobs:
  typescript-checks:
    uses: zondax/_workflows/.github/workflows/_checks-ts.yaml@v11
    with:
      # Optional overrides — defaults come from the workflow file
      # base_image defaults to zondax/ubuntu-ci:24.04 for TS checks
      disable_linting: false
      disable_tests: false
```

Each workflow accepts specific inputs. See the workflow YAML for options.

## Docker Publish Contract

The reusable Docker publish workflow [`.github/workflows/_publish-docker-bake.yaml`](./.github/workflows/_publish-docker-bake.yaml) is an orchestration layer.

**Consumer repos** define image metadata in their own `docker-bake.hcl` / Dockerfiles (tags, OCI labels, build args).

**This workflow** handles checkout, registry auth, Buildx, push, signing/provenance/SBOM options, and digests — not app-specific `BUILD_*` conventions.

## Related

- Composite actions: [Zondax/actions](https://github.com/Zondax/actions) (`@v1`)
- Consumer migration for actions: [actions/MIGRATION.md](https://github.com/Zondax/actions/blob/main/MIGRATION.md)
