#!/bin/bash

# NeuroGO Test Script
# This script tests all functionality of NeuroGO

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

print_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_output="$3"
    
    print_test "$test_name"
    
    if output=$(eval "$test_command" 2>&1); then
        if [[ -z "$expected_output" ]] || echo "$output" | grep -q "$expected_output"; then
            print_status "$test_name"
            ((TESTS_PASSED++))
            return 0
        else
            print_error "$test_name - Expected output not found"
            echo "Expected: $expected_output"
            echo "Got: $output"
            ((TESTS_FAILED++))
            return 1
        fi
    else
        print_error "$test_name - Command failed"
        echo "Error: $output"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Function to test API endpoint
test_api() {
    local endpoint="$1"
    local method="${2:-GET}"
    local data="$3"
    local expected="$4"
    
    if [[ "$method" == "POST" ]]; then
        curl -s -X POST "http://localhost:8080$endpoint" \
             -H "Content-Type: application/json" \
             -d "$data"
    else
        curl -s "http://localhost:8080$endpoint"
    fi
}

echo "🧪 NeuroGO Test Suite"
echo "===================="
echo ""

# Test 1: Health Check
run_test "Health Check" \
    "test_api '/api/health'" \
    "healthy"

# Test 2: Routes Endpoint
run_test "Routes Endpoint" \
    "test_api '/api/routes'" \
    "routes"

# Test 3: Help Command
run_test "Help Command" \
    "test_api '/api/process' 'POST' '{\"prompt\": \"help\"}'" \
    "NeuroGO"

# Test 4: Status Command
run_test "Status Command" \
    "test_api '/api/process' 'POST' '{\"prompt\": \"status\"}'" \
    "framework"

# Test 5: Chat Command (Ollama)
run_test "Chat Command (Ollama)" \
    "test_api '/api/process' 'POST' '{\"prompt\": \"chat hello\"}'" \
    ""

# Test 6: Code Generation (Ollama)
run_test "Code Generation" \
    "test_api '/api/process' 'POST' '{\"prompt\": \"generate code for hello world\"}'" \
    ""

# Test 7: WebSocket Connection
print_test "WebSocket Connection"
if command -v wscat &> /dev/null; then
    if timeout 5 wscat -c ws://localhost:8080/ws -x '{"type":"process","prompt":"help"}' 2>/dev/null | grep -q "NeuroGO"; then
        print_status "WebSocket Connection"
        ((TESTS_PASSED++))
    else
        print_error "WebSocket Connection - No response or unexpected response"
        ((TESTS_FAILED++))
    fi
else
    print_test "WebSocket Connection - Skipped (wscat not installed)"
fi

# Test 8: Static Files
run_test "Static Files" \
    "curl -s -o /dev/null -w '%{http_code}' http://localhost:8080/" \
    "200"

# Test 9: API Error Handling
run_test "API Error Handling" \
    "test_api '/api/process' 'POST' '{\"invalid\": \"json\"}'" \
    "error"

# Test 10: Provider Availability
print_test "Provider Availability"
status_response=$(test_api '/api/process' 'POST' '{"prompt": "status"}')
if echo "$status_response" | grep -q "available"; then
    print_status "Provider Availability"
    ((TESTS_PASSED++))
else
    print_error "Provider Availability - No providers available"
    ((TESTS_FAILED++))
fi

# Test 11: Docker Services
print_test "Docker Services Status"
if docker-compose ps | grep -q "Up"; then
    print_status "Docker Services Status"
    ((TESTS_PASSED++))
else
    print_error "Docker Services Status - Services not running"
    ((TESTS_FAILED++))
fi

# Test 12: Ollama Service
run_test "Ollama Service" \
    "curl -s http://localhost:11434/api/tags" \
    "models"

# Performance Tests
echo ""
echo "🚀 Performance Tests"
echo "==================="

# Test response time
print_test "Response Time Test"
start_time=$(date +%s%N)
test_api '/api/health' > /dev/null
end_time=$(date +%s%N)
response_time=$(( (end_time - start_time) / 1000000 ))

if [ $response_time -lt 1000 ]; then
    print_status "Response Time Test (${response_time}ms)"
    ((TESTS_PASSED++))
else
    print_error "Response Time Test (${response_time}ms) - Too slow"
    ((TESTS_FAILED++))
fi

# Memory usage test
print_test "Memory Usage Test"
memory_usage=$(docker stats --no-stream --format "table {{.Container}}\t{{.MemUsage}}" | grep neurogo | awk '{print $2}' | cut -d'/' -f1)
if [[ -n "$memory_usage" ]]; then
    print_status "Memory Usage Test ($memory_usage)"
    ((TESTS_PASSED++))
else
    print_error "Memory Usage Test - Could not get memory usage"
    ((TESTS_FAILED++))
fi

# Summary
echo ""
echo "📊 Test Summary"
echo "==============="
echo "Tests Passed: $TESTS_PASSED"
echo "Tests Failed: $TESTS_FAILED"
echo "Total Tests: $((TESTS_PASSED + TESTS_FAILED))"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed!${NC}"
    echo ""
    echo "Troubleshooting:"
    echo "1. Check if all services are running: docker-compose ps"
    echo "2. Check logs: docker-compose logs neurogo"
    echo "3. Restart services: docker-compose restart"
    exit 1
fi
