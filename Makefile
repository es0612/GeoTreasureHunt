.PHONY: generate build test clean lint help

# Default target
help:
	@echo "Available commands:"
	@echo "  generate  - Generate Xcode project using XcodeGen"
	@echo "  build     - Build the project"
	@echo "  test      - Run all tests"
	@echo "  clean     - Clean build artifacts"
	@echo "  lint      - Run SwiftLint"
	@echo "  help      - Show this help message"

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

# Run all tests
test:
	@echo "Testing GeoSonarCore..."
	cd Packages/GeoSonarCore && swift test
	@echo "Testing GeoSonarUI..."
	cd Packages/GeoSonarUI && swift test
	@echo "Testing GeoSonarTesting..."
	cd Packages/GeoSonarTesting && swift test

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