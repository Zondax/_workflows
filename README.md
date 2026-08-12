# _workflows

Reusable GitHub Actions workflows for standardizing CI/CD across Zondax projects.

## Pin policy

| Ref | Use when |
| --- | --- |
| **`@v12`** (current floating major) | **Preferred** for new work and deliberate upgrades |
| **`@v11`** | **Frozen** — leave existing consumers here until you migrate |
| **`@v12.0.0`** (or other semver) | Hermetic pin of the v12 line |
| **`@main`** | Bleeding edge only — can break without a major bump |

Do **not** force-move an old floating major onto new breaking/pin-heavy changes. Cut the next major (`v12`, `v13`, …) and migrate consumers when ready.

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
    uses: zondax/_workflows/.github/workflows/_checks-ts.yaml@v12
    with:
      # Optional overrides — defaults come from the workflow file
      # base_image defaults to zondax/ubuntu-ci:24.04 for TS checks
      disable_linting: false
      disable_tests: false
```

Each workflow accepts specific inputs. See the workflow YAML for options.

### Migrating from `@v11` → `@v12`

v12 is mainly **action pin hygiene** (checkout v7, artifacts v7/v8, Dependabot) plus docs. Smoke one workflow/PR, then flip remaining call sites.

```yaml
# before
uses: zondax/_workflows/.github/workflows/_checks-ts.yaml@v11
# after
uses: zondax/_workflows/.github/workflows/_checks-ts.yaml@v12
```

Release notes: https://github.com/Zondax/_workflows/releases/tag/v12.0.0

## Docker Publish Contract

The reusable Docker publish workflow [`.github/workflows/_publish-docker-bake.yaml`](./.github/workflows/_publish-docker-bake.yaml) is an orchestration layer.

**Consumer repos** define image metadata in their own `docker-bake.hcl` / Dockerfiles (tags, OCI labels, build args).

**This workflow** handles checkout, registry auth, Buildx, push, signing/provenance/SBOM options, and digests — not app-specific `BUILD_*` conventions.

## Related

- Composite actions: [Zondax/actions](https://github.com/Zondax/actions) (`@v1`)
- Consumer migration for actions: [actions/MIGRATION.md](https://github.com/Zondax/actions/blob/main/MIGRATION.md)
