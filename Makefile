default: help

-include Makefile.settings.mk

# Core modules
-include .make/Makefile.libs.mk
-include .make/Makefile.help.mk
-include .make/Makefile.macros.mk
-include .make/Makefile.misc.mk

# Language-specific modules
-include .make/Makefile.golang.mk
-include .make/Makefile.rust.mk
-include .make/Makefile.node.mk

# Infrastructure modules
-include .make/Makefile.docker.mk
-include .make/Makefile.infra.mk
-include .make/Makefile.yaml.mk

# Local overrides (optional)
-include Makefile.local.mk

# =============================================================================
# Base Images - Local Development (Docker Bake)
# =============================================================================

.PHONY: bake bake-load bake-list help

## Build all base images (no push)
bake:
	docker buildx bake -f .docker/docker-bake.hcl

## Build and load base images into local Docker
bake-load:
	docker buildx bake -f .docker/docker-bake.hcl --load

## List available bake targets
bake-list:
	@docker buildx bake -f .docker/docker-bake.hcl --print | jq -r '.target | keys[]'

## Show help
help:
	@echo "Bake Commands:"
	@echo "  make bake        - Build all base images"
	@echo "  make bake-load   - Build and load into local Docker"
	@echo "  make bake-list   - List available targets"
	@echo ""
	@echo "Build specific target:"
	@echo "  docker buildx bake -f .docker/docker-bake.hcl ubuntu-22-dev --load"
	@echo ""
	@echo "Build with custom tag:"
	@echo '  docker buildx bake -f .docker/docker-bake.hcl --set "*.tags=mytest:local" --load'
