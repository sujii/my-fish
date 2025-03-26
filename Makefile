# Configuration
SHELL := /bin/bash
.DEFAULT_GOAL := help

# Fish shell configuration
FISH ?= fish
FISH_VERSION := $(shell $(FISH) --version 2>/dev/null | cut -d' ' -f3 || printf "0.0.0")
MIN_FISH_VERSION := 3.0.0

# Directory paths
SCRIPTS_DIR := ./scripts
CONFIG_DIR := $(HOME)/.config/fish
BACKUP_DIR := $(HOME)/.config/backup

# Files
SETUP_SCRIPT := $(SCRIPTS_DIR)/setup.sh
CONFIG_FILE := $(CONFIG_DIR)/config.fish
BACKUP_FILE := $(BACKUP_DIR)/config.fish.bak

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
BOLD := \033[1m
RESET := \033[0m

# Formatting helpers
INFO := $(BLUE)$(BOLD)
SUCCESS := $(GREEN)$(BOLD)
WARN := $(YELLOW)$(BOLD)
ERROR := $(RED)$(BOLD)

# Targets
.PHONY: all clean help setup test validate backup restore

## Install and configure fish shell
all: validate setup

## Setup fish shell and configurations
setup:
	@printf "$(INFO)Setting up...$(RESET)\n"
	@command -v $(FISH) >/dev/null 2>&1 || { \
		printf "$(ERROR)Error: fish not installed$(RESET)\n" >&2; \
		exit 1; \
	}
	@printf "$(SUCCESS)Setup complete!$(RESET)\n"

## Validate requirements before setup
validate:
	@printf "$(INFO)Validating requirements...$(RESET)\n"
	@command -v $(FISH) >/dev/null 2>&1 || { \
		printf "$(ERROR)Error: fish shell is not installed$(RESET)\n" >&2; \
		exit 1; \
	}
	@if [ ! -d "$(SCRIPTS_DIR)" ]; then \
		printf "$(ERROR)Error: $(SCRIPTS_DIR) directory not found$(RESET)\n" >&2; \
		exit 1; \
	fi
	@if [ ! -d "$(CONFIG_DIR)" ]; then \
		printf "$(ERROR)Error: $(CONFIG_DIR) directory not found$(RESET)\n" >&2; \
		exit 1; \
	fi
	@printf "$(SUCCESS)All requirements met.$(RESET)\n"

## Backup existing configuration
backup:
	@printf "$(INFO)Creating backup...$(RESET)\n"
	@mkdir -p "$(BACKUP_DIR)"
	@if [ -f "$(CONFIG_FILE)" ]; then \
		cp -f "$(CONFIG_FILE)" "$(BACKUP_FILE)" && \
		printf "$(SUCCESS)Backup created at $(BACKUP_FILE)$(RESET)\n"; \
	else \
		printf "$(WARN)No existing configuration to backup$(RESET)\n"; \
	fi

## Restore configuration from backup
restore:
	@printf "$(INFO)Restoring from backup...$(RESET)\n"
	@if [ -f "$(BACKUP_FILE)" ]; then \
		cp -f "$(BACKUP_FILE)" "$(CONFIG_FILE)" && \
		printf "$(SUCCESS)Configuration restored from backup$(RESET)\n"; \
	else \
		printf "$(ERROR)No backup file found at $(BACKUP_FILE)$(RESET)\n" >&2; \
		exit 1; \
	fi


## Clean up temporary files and backups
clean:
	@printf "$(INFO)Cleaning up...$(RESET)\n"
	@if [ -d "$(BACKUP_DIR)" ]; then \
		rm -rf "$(BACKUP_DIR)"; \
	fi
	@find . \( \
		-type f \
		-name "*.bak" -o \
		-name "*~" -o \
		-name "*.log" \
	\) -delete 2>/dev/null || true
	@find . -type d -empty -delete 2>/dev/null || true
	@printf "$(SUCCESS)Cleanup completed!$(RESET)\n"

## Run tests if they exist
test:
	@printf "$(INFO)Running tests...$(RESET)\n"
	@if [ -d "tests" ] && [ -x "tests/run_tests.sh" ]; then \
		./tests/run_tests.sh || { \
			printf "$(ERROR)Tests failed$(RESET)\n" >&2; \
			exit 1; \
		}; \
		printf "$(SUCCESS)All tests passed!$(RESET)\n"; \
	else \
		printf "$(WARN)No tests found or test script not executable$(RESET)\n" >&2; \
		exit 0; \
	fi

## Show help message
help:
	@printf "\n$(BOLD)Usage:$(RESET)\n"
	@printf "  make $(BLUE)[target]$(RESET)\n\n"
	@printf "$(BOLD)Targets:$(RESET)\n"
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  $(YELLOW)%-15s$(RESET) %s\n", helpCommand, helpMessage; \
		} \
	} { lastLine = $$0 }' $(MAKEFILE_LIST)
	@printf "\n$(BOLD)Configuration:$(RESET)\n"
	@printf "  FISH          = $(BLUE)$(FISH)$(RESET)\n"
	@printf "  FISH_VERSION  = $(BLUE)$(FISH_VERSION)$(RESET)\n"
	@printf "  SCRIPTS_DIR   = $(BLUE)$(SCRIPTS_DIR)$(RESET)\n"
	@printf "  CONFIG_DIR    = $(BLUE)$(CONFIG_DIR)$(RESET)\n"
	@printf "  BACKUP_DIR    = $(BLUE)$(BACKUP_DIR)$(RESET)\n\n"
