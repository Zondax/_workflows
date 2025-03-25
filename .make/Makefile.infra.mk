KUBECONFORM_EXTRA_CRD_VERSION := main
KUBECONFORM_EXTRA_CRD_URL := https://raw.githubusercontent.com/datreeio/CRDs-catalog/$(KUBECONFORM_EXTRA_CRD_VERSION)

-include Makefile.yaml.mk

## Infra
infra-checks: ## Infra Checks
	@$(MAKE) yaml-lint
	@$(MAKE) infra-kubeconform

infra-kubeconform: ## Infra Kubeconform
	@echo "\nRunning kubeconform on Kubernetes manifests..."
	@kubeconform \
		-schema-location default \
		-schema-location '$(KUBECONFORM_EXTRA_CRD_URL)/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json' \
		-ignore-missing-schemas \
		-n 16 \
		-ignore-filename-pattern '\.infra/.*/values\.yaml' \
		-ignore-filename-pattern '\.infra/.*/name-remapping\.yaml' \
		-summary .infra/

KUBECONFORM_VERSION ?= v0.6.7
KUBECONFORM_ARCH ?= linux-amd64
KUBECONFORM_URL ?= https://github.com/yannh/kubeconform/releases/download

infra-kubeconform-install: ## Install kubeconform
	@echo "Installing kubeconform..."
	@curl -sL $(KUBECONFORM_URL)/$(KUBECONFORM_VERSION)/kubeconform-$(KUBECONFORM_ARCH).tar.gz | tar xzvOf - kubeconform > /usr/local/bin/kubeconform
	@chmod 755 /usr/local/bin/kubeconform
	@chmod +x /usr/local/bin/kubeconform
	@echo "kubeconform installed successfully"

.PHONY: infra-checks infra-lint infra-kubeconform
.PHONY: infra-kubeconform-install

