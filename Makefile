BINARY_NAME = vash
INSTALL_DIR = /usr/local/bin

.PHONY: help build release test install uninstall clean lint format generate

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
	@echo "  generate   Regenerate OpenAPI client from openapi.yaml"

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
