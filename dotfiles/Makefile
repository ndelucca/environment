SHELL := /bin/bash

DOTFILES_DIR := $(CURDIR)
TARGET_DIR := $(HOME)
STOW := $(shell which stow)
AGE := $(shell which age)

MODULES := $(shell find $(DOTFILES_DIR) -mindepth 1 -maxdepth 1 -type d -printf '%f\n')

.PHONY: help
help:
	@echo "Usage: make [option]"
	@echo "Available options:"
	@echo " help   - Show this help message."
	@echo " check  - Verify if 'stow' and 'age' are installed."
	@echo " stow   - Install all dotfiles (creates symlinks)."
	@echo " unstow - Remove the symlinks for all dotfiles."
	@echo " backup - Renames conflicting files with a .bak extension."

.PHONY: check
check:
	@echo "Checking if stow and age are installed..."
	@if [ -z "$(STOW)" ]; then \
		echo "Error: 'stow' is not installed or not in the PATH."; \
		exit 1; \
	fi
	@if [ -z "$(AGE)" ]; then \
		echo "Error: 'age' is not installed or not in the PATH."; \
		exit 1; \
	fi

.PHONY: stow
stow: check backup
	@echo "Installing dotfiles with stow..."
	@stow -t $(TARGET_DIR) -d $(DOTFILES_DIR) $(MODULES)
	@echo "Dotfiles installed successfully."

.PHONY: unstow
unstow   :
	@echo "Uninstalling dotfiles with stow..."
	@stow -D -t $(TARGET_DIR) -d $(DOTFILES_DIR) $(MODULES)
	@echo "Dotfiles uninstalled successfully."

.PHONY: backup
backup:
	@echo "Creating backups for conflicting files in $(TARGET_DIR)..."
	@for module in $(MODULES); do \
		echo "Checking module '$$module' for conflicts..."; \
		for file in $(find $(DOTFILES_DIR)/$$module -type f); do \
			target=$$(echo "$$file" | sed "s|^$(DOTFILES_DIR)/$$module/|$(TARGET_DIR)/|"); \
			if [ -e "$$target" ] && [ ! -L "$$target" ]; then \
				mv -v "$$target" "$$target".bak; \
			fi; \
		done; \
	done
	@echo "Backup process complete."

.DEFAULT_GOAL := help
