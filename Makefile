default: help

-include Makefile.settings.mk

-include .make/Makefile.libs.mk
-include .make/Makefile.docker.mk
-include .make/Makefile.help.mk
-include .make/Makefile.infra.mk
-include .make/Makefile.yaml.mk

-include Makefile.local.mk
