# Configuration
SHELL := /bin/bash
.DEFAULT_GOAL := help

# Colors for terminal output
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)

# Directories
SCRIPTS_DIR := ./scripts
CONFIG_DIR  := ./config

# Target-specific variables
SETUP_SCRIPT := $(SCRIPTS_DIR)/setup.sh

# Ensure required directories exist
$(SCRIPTS_DIR):
	mkdir -p $(SCRIPTS_DIR)

# Check if setup script exists
$(SETUP_SCRIPT):
	$(error Setup script not found at $(SETUP_SCRIPT))

.PHONY: setup help clean verify

setup: verify ## Set up the development environment
	@echo "$(GREEN)Setting up the development environment...$(RESET)"
	@if [ -x $(SETUP_SCRIPT) ]; then \
		$(SETUP_SCRIPT); \
	else \
		chmod +x $(SETUP_SCRIPT) && $(SETUP_SCRIPT); \
	fi

verify: $(SETUP_SCRIPT) ## Verify that all required files exist
	@echo "$(GREEN)Verifying setup requirements...$(RESET)"

clean: ## Clean up generated files and directories
	@echo "$(YELLOW)Cleaning up...$(RESET)"
	@rm -rf $(CONFIG_DIR)/*.bak
	@echo "$(GREEN)Cleanup complete$(RESET)"

help: ## Display this help message
	@echo "Usage:"
	@echo "  make $(YELLOW)<target>$(RESET)"
	@echo
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*?##/ { printf "  $(YELLOW)%-15s$(WHITE)%s$(RESET)\n", $$1, $$2 }' $(MAKEFILE_LIST)
