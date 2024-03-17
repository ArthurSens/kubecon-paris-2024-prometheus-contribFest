.PHONY: help
help: ## Display this help and any documented user-facing targets. Other undocumented targets may be present in the Makefile.
help:
	@awk 'BEGIN {FS = ": ##"; printf "Usage:\n  make <target>\n\nTargets:\n"} /^[a-zA-Z0-9_\.\-\/%]+: ##/ { printf "  %-45s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

cluster-create: ## Bootstraps the workshop cluster
	@bash ./scripts/cluster_create.sh

cluster-delete: ## Deletes the workshop cluster
	@bash ./scripts/cluster_delete.sh

scenario-0: ## Deploy the scenario 0
	@bash ./scripts/scenario_0.sh

lint-shellcheck: ## Run shellcheck
	bash ./scripts/shellcheck.sh
