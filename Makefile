.PHONY: generate build test test-unit test-e2e test-e2e-flow test-e2e-scenarios test-e2e-accessibility test-e2e-performance test-e2e-integration clean lint help

# Default target
help:
	@echo "Available commands:"
	@echo "  generate              - Generate Xcode project using XcodeGen"
	@echo "  build                 - Build the project"
	@echo "  test                  - Run all tests (unit + E2E)"
	@echo "  test-unit             - Run unit tests only"
	@echo "  test-e2e              - Run all E2E tests"
	@echo "  test-e2e-flow         - Run complete treasure hunt flow tests"
	@echo "  test-e2e-scenarios    - Run multiple scenario tests"
	@echo "  test-e2e-accessibility - Run accessibility tests"
	@echo "  test-e2e-performance  - Run performance tests"
	@echo "  test-e2e-integration  - Run comprehensive integration tests"
	@echo "  clean                 - Clean build artifacts"
	@echo "  lint                  - Run SwiftLint"
	@echo "  help                  - Show this help message"

# Generate Xcode project
generate:
	xcodegen generate

# Build the project
build: generate
	xcodebuild build \
		-project GeoSonarHunt.xcodeproj \
		-scheme GeoSonarHuntApp \
		-destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
		CODE_SIGNING_ALLOWED=NO

# Run all tests (unit + E2E)
test: test-unit test-e2e

# Run unit tests only
test-unit:
	@echo "Testing GeoSonarCore..."
	cd Packages/GeoSonarCore && swift test
	@echo "Testing GeoSonarUI..."
	cd Packages/GeoSonarUI && swift test
	@echo "Testing GeoSonarTesting..."
	cd Packages/GeoSonarTesting && swift test

# Run all E2E tests
test-e2e: generate
	@echo "Running comprehensive E2E test suite..."
	./Tests/run_e2e_tests.sh all

# Run complete treasure hunt flow tests
test-e2e-flow: generate
	@echo "Running treasure hunt flow tests..."
	./Tests/run_e2e_tests.sh flow

# Run multiple scenario tests
test-e2e-scenarios: generate
	@echo "Running multiple scenario tests..."
	./Tests/run_e2e_tests.sh scenarios

# Run accessibility tests
test-e2e-accessibility: generate
	@echo "Running accessibility tests..."
	./Tests/run_e2e_tests.sh accessibility

# Run performance tests
test-e2e-performance: generate
	@echo "Running performance tests..."
	./Tests/run_e2e_tests.sh performance

# Run comprehensive integration tests
test-e2e-integration: generate
	@echo "Running comprehensive integration tests..."
	./Tests/run_e2e_tests.sh integration

# Clean build artifacts
clean:
	rm -rf .build
	rm -rf DerivedData
	xcodebuild clean \
		-project GeoSonarHunt.xcodeproj \
		-scheme GeoSonarHuntApp || true

# Run SwiftLint
lint:
	swiftlint lint

# Install dependencies
install:
	@echo "Installing XcodeGen..."
	brew install xcodegen || true
	@echo "Installing SwiftLint..."
	brew install swiftlint || true