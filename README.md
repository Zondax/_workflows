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

### Trusted node-local Kache rollout

`_checks-rs.yaml` can route an opted-in Linux job to `zondax-kache-linux` with
`kache_node_cache: true`. The shared store's registered blobs are capped at
`50GiB` by default; override `kache_node_cache_max_size` only with a matching
node-capacity review.

Before rollout:

- verify the builder disks were expanded and Kubernetes reports the expected
  free/allocatable space;
- pin a Kache release with job-local runtime support and a compatible
  `kache-action@v1` release;
- set a stable, build-specific `kache_manifest_key` in the caller. The action
  also uses it as the namespace, enabling manifest/shard and packed prefetch;
  an empty key disables the L2 selector and falls back to object-by-object v3;
- verify the `zondax-kache-trusted` runner group selects only the intended
  private repository, disallows public repositories, and that repository does
  not allow forks; require `restricted_to_workflows=true` and select exactly
  `Zondax/_workflows/.github/workflows/_checks-rs.yaml@<release SHA>`;
- pin the caller's `uses:` entry to that same immutable `_checks-rs.yaml` release
  SHA rather than a floating branch or major tag;
- deploy the restricted scale set, keeping its one-cache-job-per-node
  anti-affinity.

Enable the caller flag for one representative job first. Compare a cold run and
a warm run, and check the Kache report plus `df`/`du`, daemon status, GC output,
and `kache doctor --verify` before expanding usage. The cold canary must report
the expected manifest/namespace and non-zero packed-prefetch discovery;
otherwise it is only exercising the v3 fallback.

Rollback is caller-first: set `kache_node_cache: false` so new jobs return to
the ordinary runner pool, drain active jobs, then suspend the Kache
runner-scale-set HelmRelease through GitOps/Flux if needed. The cache can remain
for diagnosis and a later retry. Only platform operators own purging the exact
per-node trust-domain directory after the scale set is drained; workflows,
actions, and callers must not delete the shared store.

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
