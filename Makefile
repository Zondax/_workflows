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
