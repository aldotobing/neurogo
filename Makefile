.PHONY: build run dev test clean docker-build docker-run docker-dev setup help

# Default target
help:
	@echo "NeuroGO Framework - Available Commands:"
	@echo ""
	@echo "Development:"
	@echo "  setup     - Install dependencies and setup development environment"
	@echo "  dev       - Run development server with hot reload"
	@echo "  run       - Run the application"
	@echo "  test      - Run tests"
	@echo ""
	@echo "Building:"
	@echo "  build     - Build the application"
	@echo "  clean     - Clean build artifacts"
	@echo ""
	@echo "Docker:"
	@echo "  docker-build - Build Docker image"
	@echo "  docker-run   - Run with Docker Compose"
	@echo "  docker-dev   - Run development environment with Docker"
	@echo ""

# Setup development environment
setup:
	@echo "Setting up NeuroGO development environment..."
	go mod tidy
	go mod download
	@if [ ! -f .env ]; then cp .env.example .env; echo "Created .env file from template"; fi
	@echo "Setup complete! Edit .env file with your API keys."

# Run development server with hot reload
dev:
	@echo "Starting NeuroGO development server..."
	@if command -v air > /dev/null; then \
		air -c .air.toml; \
	else \
		echo "Installing air for hot reloading..."; \
		go install github.com/cosmtrek/air@latest; \
		air -c .air.toml; \
	fi

# Run the application
run:
	@echo "Starting NeuroGO server..."
	go run cmd/server/main.go

# Build the application
build:
	@echo "Building NeuroGO..."
	go build -o bin/neurogo cmd/server/main.go
	@echo "Build complete! Binary available at bin/neurogo"

# Run tests
test:
	@echo "Running tests..."
	go test -v ./...

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf bin/
	rm -rf tmp/
	go clean

# Docker commands
docker-build:
	@echo "Building Docker image..."
	docker build -t neurogo:latest .

docker-run:
	@echo "Starting NeuroGO with Docker Compose..."
	docker-compose up --build

docker-dev:
	@echo "Starting NeuroGO development environment with Docker..."
	docker-compose --profile dev up --build

# Install dependencies
deps:
	go mod tidy
	go mod download

# Format code
fmt:
	go fmt ./...

# Lint code
lint:
	@if command -v golangci-lint > /dev/null; then \
		golangci-lint run; \
	else \
		echo "golangci-lint not installed. Install it from https://golangci-lint.run/"; \
	fi

# Generate documentation
docs:
	@echo "Generating documentation..."
	godoc -http=:6060
	@echo "Documentation server running at http://localhost:6060"
