# Define the name of the binary/output file
APP_NAME := go-scratch
BIN_DIR := bin

# Go related commands and flags
GO := go
GO_BUILD := $(GO) build
GO_RUN := $(GO) run
GO_TEST := $(GO) test
GO_MOD_TIDY := $(GO) mod tidy

# Default target: what gets run when you just type 'make'
.PHONY: default
default: help

# Build the application into the bin/ directory
.PHONY: build
build:
	@mkdir -p $(BIN_DIR)
	$(GO_BUILD) -o $(BIN_DIR)/$(APP_NAME) ./cmd/$(APP_NAME)

# Build a stripped, production-optimized binary (smaller file size)
.PHONY: build-prod
build-prod:
	@mkdir -p $(BIN_DIR)
	$(GO_BUILD) -ldflags="-s -w" -trimpath -o $(BIN_DIR)/$(APP_NAME) ./cmd/$(APP_NAME)

# Run the application locally
.PHONY: run
run:
	$(GO_RUN) ./cmd/$(APP_NAME)

# Run all tests (verbose mode)
.PHONY: test
test:
	$(GO_TEST) -v ./...

# Run tests and generate a coverage report
.PHONY: test-coverage
test-coverage:
	$(GO_TEST) -coverprofile=coverage.out ./...
	$(GO) tool cover -html=coverage.out

# Clean the bin/ directory and test cache
.PHONY: clean
clean:
	@rm -rf $(BIN_DIR) coverage.out
	$(GO) clean -cache -testcache

# Tidy the go.mod module (add missing, remove unused dependencies)
.PHONY: tidy
tidy:
	$(GO_MOD_TIDY)

# Install the golangci-lint tool
.PHONY: install-lint
install-lint:
	$(GO) install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Run the linter (requires install-lint to be run first)
.PHONY: lint
lint:
	golangci-lint run ./...

# Show help - the default target
.PHONY: help
help:
	@echo "go-scratch project Makefile"
	@echo "==========================="
	@echo "Available targets:"
	@echo "  build         - Build the binary to ./bin/"
	@echo "  build-prod    - Build an optimized production binary"
	@echo "  run           - Run the application"
	@echo "  test          - Run all tests"
	@echo "  test-coverage - Run tests and show coverage report"
	@echo "  clean         - Remove build artifacts and clean cache"
	@echo "  tidy          - Tidy go.mod dependencies"
	@echo "  install-lint  - Install the golangci-lint tool"
	@echo "  lint          - Run golangci-lint (run install-lint first)"
	@echo "  help          - Show this help message"
