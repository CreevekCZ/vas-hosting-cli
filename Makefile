BINARY_NAME = vash
INSTALL_DIR = /usr/local/bin

.PHONY: help build release test install uninstall clean lint format generate \
        completions-zsh completions-bash completions-fish install-completions archive

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  build      Build debug binary"
	@echo "  release    Build optimised release binary"
	@echo "  test       Run all tests"
	@echo "  install    Build release and install to $(INSTALL_DIR)"
	@echo "  uninstall  Remove $(BINARY_NAME) from $(INSTALL_DIR)"
	@echo "  clean      Clean build artifacts"
	@echo "  lint       Run SwiftLint"
	@echo "  format     Run SwiftFormat"
	@echo "  generate             Regenerate OpenAPI client from openapi.yaml"
	@echo "  completions-zsh      Print zsh completion script"
	@echo "  completions-bash     Print bash completion script"
	@echo "  completions-fish     Print fish completion script"
	@echo "  install-completions  Install completions for current shell (zsh/bash/fish)"
	@echo "  archive              Build release tarball for Homebrew (requires VERSION=x.y.z)"

build:
	swift build

release:
	swift build -c release

test:
	swift test

install: release
	cp .build/release/$(BINARY_NAME) $(INSTALL_DIR)/$(BINARY_NAME)
	@echo "Installed $(BINARY_NAME) to $(INSTALL_DIR)/$(BINARY_NAME)"

uninstall:
	rm -f $(INSTALL_DIR)/$(BINARY_NAME)
	@echo "Removed $(BINARY_NAME) from $(INSTALL_DIR)"

clean:
	swift package clean

lint:
	swiftlint lint --strict

format:
	swiftformat Sources Tests --swiftversion 5.9

generate:
	swift package plugin --allow-writing-to-package-directory generate-code-from-openapi --target VasHostingClient

archive: release
	@if [ -z "$(VERSION)" ]; then echo "Usage: make archive VERSION=x.y.z"; exit 1; fi
	@ARCHIVE="$(BINARY_NAME)-v$(VERSION)-darwin-arm64.tar.gz"; \
	tar -czf "$$ARCHIVE" -C .build/release $(BINARY_NAME); \
	SHA=$$(shasum -a 256 "$$ARCHIVE" | awk '{print $$1}'); \
	echo "Created $$ARCHIVE"; \
	echo "SHA256: $$SHA"

completions-zsh: build
	.build/debug/$(BINARY_NAME) --generate-completion-script zsh

completions-bash: build
	.build/debug/$(BINARY_NAME) --generate-completion-script bash

completions-fish: build
	.build/debug/$(BINARY_NAME) --generate-completion-script fish

install-completions: build
	@SHELL_NAME=$$(basename "$$SHELL"); \
	case "$$SHELL_NAME" in \
	  zsh) \
	    DEST="$${HOME}/.zsh/completions/_$(BINARY_NAME)"; \
	    mkdir -p "$$(dirname $$DEST)"; \
	    .build/debug/$(BINARY_NAME) --generate-completion-script zsh > "$$DEST"; \
	    echo "Installed zsh completions to $$DEST"; \
	    echo "Make sure $${HOME}/.zsh/completions is in your fpath (add to ~/.zshrc):"; \
	    echo "  fpath=(~/.zsh/completions \$$fpath)"; \
	    echo "  autoload -Uz compinit && compinit"; \
	    ;; \
	  bash) \
	    DEST="$${HOME}/.bash_completion.d/$(BINARY_NAME)"; \
	    mkdir -p "$$(dirname $$DEST)"; \
	    .build/debug/$(BINARY_NAME) --generate-completion-script bash > "$$DEST"; \
	    echo "Installed bash completions to $$DEST"; \
	    echo "Source it from ~/.bashrc:"; \
	    echo "  source ~/.bash_completion.d/$(BINARY_NAME)"; \
	    ;; \
	  fish) \
	    DEST="$${HOME}/.config/fish/completions/$(BINARY_NAME).fish"; \
	    mkdir -p "$$(dirname $$DEST)"; \
	    .build/debug/$(BINARY_NAME) --generate-completion-script fish > "$$DEST"; \
	    echo "Installed fish completions to $$DEST"; \
	    ;; \
	  *) \
	    echo "Unknown shell: $$SHELL_NAME. Use completions-zsh, completions-bash, or completions-fish."; \
	    exit 1; \
	    ;; \
	esac
