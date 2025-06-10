#!/bin/bash

# NeuroGO Docker Setup Script
# This script sets up and runs NeuroGO with Docker

set -e

echo "🧠 NeuroGO Docker Setup Script"
echo "================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if Docker is installed
check_docker() {
    print_step "Checking Docker installation..."
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        echo "Visit: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        echo "Visit: https://docs.docker.com/compose/install/"
        exit 1
    fi
    
    print_status "Docker and Docker Compose are installed ✓"
}

# Check if Docker daemon is running
check_docker_daemon() {
    print_step "Checking Docker daemon..."
    if ! docker info &> /dev/null; then
        print_error "Docker daemon is not running. Please start Docker first."
        exit 1
    fi
    print_status "Docker daemon is running ✓"
}

# Setup environment file
setup_env() {
    print_step "Setting up environment file..."
    if [ ! -f .env ]; then
        cp .env.example .env
        print_status "Created .env file from template"
        print_warning "Please edit .env file to add your API keys if you have them"
    else
        print_status ".env file already exists"
    fi
}

# Pull required Docker images
pull_images() {
    print_step "Pulling required Docker images..."
    docker-compose pull ollama
    print_status "Docker images pulled successfully ✓"
}

# Build NeuroGO image
build_neurogo() {
    print_step "Building NeuroGO Docker image..."
    docker-compose build neurogo
    print_status "NeuroGO image built successfully ✓"
}

# Start services
start_services() {
    print_step "Starting NeuroGO services..."
    docker-compose up -d
    
    print_status "Services started! Waiting for them to be ready..."
    
    # Wait for Ollama to be ready
    print_step "Waiting for Ollama to start..."
    timeout=60
    counter=0
    while ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; do
        if [ $counter -ge $timeout ]; then
            print_error "Ollama failed to start within $timeout seconds"
            exit 1
        fi
        sleep 2
        counter=$((counter + 2))
        echo -n "."
    done
    echo ""
    print_status "Ollama is ready ✓"
    
    # Pull a default model
    print_step "Pulling default Ollama model (llama3.1)..."
    docker-compose exec ollama ollama pull llama3.1
    print_status "Default model pulled ✓"
    
    # Wait for NeuroGO to be ready
    print_step "Waiting for NeuroGO to start..."
    counter=0
    while ! curl -s http://localhost:8080/api/health > /dev/null 2>&1; do
        if [ $counter -ge $timeout ]; then
            print_error "NeuroGO failed to start within $timeout seconds"
            exit 1
        fi
        sleep 2
        counter=$((counter + 2))
        echo -n "."
    done
    echo ""
    print_status "NeuroGO is ready ✓"
}

# Test the setup
test_setup() {
    print_step "Testing NeuroGO setup..."
    
    # Test health endpoint
    if curl -s http://localhost:8080/api/health | grep -q "healthy"; then
        print_status "Health check passed ✓"
    else
        print_error "Health check failed"
        return 1
    fi
    
    # Test a simple command
    response=$(curl -s -X POST http://localhost:8080/api/process \
        -H "Content-Type: application/json" \
        -d '{"prompt": "help"}')
    
    if echo "$response" | grep -q "NeuroGO"; then
        print_status "Command processing test passed ✓"
    else
        print_error "Command processing test failed"
        return 1
    fi
    
    print_status "All tests passed! ✓"
}

# Show final information
show_info() {
    echo ""
    echo "🎉 NeuroGO is now running!"
    echo "=========================="
    echo ""
    echo "🌐 Playground UI: http://localhost:8080"
    echo "🔗 API Endpoint: http://localhost:8080/api"
    echo "🤖 Ollama API: http://localhost:11434"
    echo ""
    echo "📝 Try these commands in the playground:"
    echo "  • help"
    echo "  • status"
    echo "  • chat hello world"
    echo "  • generate code for a web server"
    echo ""
    echo "🛠️  Useful Docker commands:"
    echo "  • docker-compose logs -f neurogo    # View logs"
    echo "  • docker-compose stop               # Stop services"
    echo "  • docker-compose down               # Stop and remove containers"
    echo "  • docker-compose restart neurogo    # Restart NeuroGO"
    echo ""
    echo "📚 Edit .env file to add API keys for more providers!"
}

# Main execution
main() {
    echo "Starting NeuroGO Docker setup..."
    echo ""
    
    check_docker
    check_docker_daemon
    setup_env
    pull_images
    build_neurogo
    start_services
    
    if test_setup; then
        show_info
    else
        print_error "Setup completed but tests failed. Check the logs:"
        echo "docker-compose logs neurogo"
        exit 1
    fi
}

# Handle script arguments
case "${1:-}" in
    "start")
        print_step "Starting existing services..."
        docker-compose up -d
        show_info
        ;;
    "stop")
        print_step "Stopping services..."
        docker-compose stop
        print_status "Services stopped"
        ;;
    "restart")
        print_step "Restarting services..."
        docker-compose restart
        show_info
        ;;
    "logs")
        docker-compose logs -f neurogo
        ;;
    "clean")
        print_step "Cleaning up Docker resources..."
        docker-compose down -v
        docker system prune -f
        print_status "Cleanup completed"
        ;;
    "test")
        test_setup
        ;;
    *)
        main
        ;;
esac
