#!/bin/bash

# Quality Assurance Test Suite for Geo Sonar Hunt
# Comprehensive testing before App Store submission

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 Geo Sonar Hunt - Quality Assurance Test Suite${NC}"
echo "=================================================="

# Test results tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
    ((PASSED_TESTS++))
    ((TOTAL_TESTS++))
}

print_failure() {
    echo -e "${RED}❌ $1${NC}"
    ((FAILED_TESTS++))
    ((TOTAL_TESTS++))
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

run_test_suite() {
    local suite_name="$1"
    local test_command="$2"
    
    echo -e "${BLUE}🔍 Running $suite_name...${NC}"
    
    if eval "$test_command"; then
        print_status "$suite_name completed successfully"
        return 0
    else
        print_failure "$suite_name failed"
        return 1
    fi
}

# Generate Xcode project first
echo -e "${BLUE}🔧 Generating Xcode project...${NC}"
xcodegen generate
print_status "Xcode project generated"

echo ""
echo -e "${BLUE}📋 Test Suite Overview:${NC}"
echo "1. Unit Tests (GeoSonarCore)"
echo "2. Unit Tests (GeoSonarUI)" 
echo "3. Unit Tests (GeoSonarTesting)"
echo "4. Integration Tests"
echo "5. UI Tests"
echo "6. Performance Tests"
echo "7. Accessibility Tests"
echo "8. Memory Leak Tests"
echo "9. Build Validation"
echo "10. Static Analysis"
echo ""

# 1. Core Package Unit Tests
run_test_suite "GeoSonarCore Unit Tests" \
    "swift test --package-path Packages/GeoSonarCore"

# 2. UI Package Unit Tests  
run_test_suite "GeoSonarUI Unit Tests" \
    "swift test --package-path Packages/GeoSonarUI"

# 3. Testing Package Unit Tests
run_test_suite "GeoSonarTesting Unit Tests" \
    "swift test --package-path Packages/GeoSonarTesting"

# 4. Integration Tests
run_test_suite "Integration Tests" \
    "xcodebuild test -scheme GeoSonarHuntApp -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -only-testing:GeoSonarHuntAppTests -quiet"

# 5. UI Tests - Complete Flow
run_test_suite "UI Tests - Complete Treasure Hunt Flow" \
    "xcodebuild test -scheme GeoSonarHuntApp -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -only-testing:GeoSonarHuntAppUITests/CompleteTreasureHuntFlowTests -quiet"

# 6. UI Tests - Multiple Scenarios
run_test_suite "UI Tests - Multiple Scenarios" \
    "xcodebuild test -scheme GeoSonarHuntApp -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -only-testing:GeoSonarHuntAppUITests/MultipleScenarioTests -quiet"

# 7. Performance Tests
run_test_suite "Performance Tests" \
    "xcodebuild test -scheme GeoSonarHuntApp -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -only-testing:GeoSonarHuntAppUITests/PerformanceTests -quiet"

# 8. Accessibility Tests
run_test_suite "Accessibility Tests" \
    "xcodebuild test -scheme GeoSonarHuntApp -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -only-testing:GeoSonarHuntAppUITests/AccessibilityTests -quiet"

# 9. Comprehensive Integration Tests
run_test_suite "Comprehensive Integration Tests" \
    "xcodebuild test -scheme GeoSonarHuntApp -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -only-testing:GeoSonarHuntAppUITests/ComprehensiveIntegrationTests -quiet"

# 10. Build Validation - Debug
echo -e "${BLUE}🔨 Validating Debug Build...${NC}"
if xcodebuild build -scheme GeoSonarHuntApp -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -configuration Debug -quiet; then
    print_status "Debug build validation passed"
else
    print_failure "Debug build validation failed"
fi

# 11. Build Validation - Release
echo -e "${BLUE}🔨 Validating Release Build...${NC}"
if xcodebuild build -scheme GeoSonarHuntApp -destination 'generic/platform=iOS' -configuration Release -quiet; then
    print_status "Release build validation passed"
else
    print_failure "Release build validation failed"
fi

# 12. Static Analysis
echo -e "${BLUE}🔍 Running Static Analysis...${NC}"
if xcodebuild analyze -scheme GeoSonarHuntApp -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -quiet; then
    print_status "Static analysis completed without issues"
else
    print_failure "Static analysis found issues"
fi

# 13. SwiftLint (if available)
if command -v swiftlint &> /dev/null; then
    echo -e "${BLUE}📏 Running SwiftLint...${NC}"
    if swiftlint --quiet; then
        print_status "SwiftLint validation passed"
    else
        print_failure "SwiftLint found style issues"
    fi
else
    print_warning "SwiftLint not installed - skipping style checks"
fi

# 14. Package Dependencies Check
echo -e "${BLUE}📦 Checking Package Dependencies...${NC}"
if swift package resolve; then
    print_status "Package dependencies resolved successfully"
else
    print_failure "Package dependency resolution failed"
fi

# 15. Memory and Performance Validation
echo -e "${BLUE}🧠 Memory and Performance Validation...${NC}"
if xcodebuild test -scheme GeoSonarHuntApp -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -only-testing:GeoSonarCoreTests/PerformanceOptimizationTests -quiet; then
    print_status "Memory and performance validation passed"
else
    print_failure "Memory and performance validation failed"
fi

# Test Results Summary
echo ""
echo "=================================================="
echo -e "${BLUE}📊 QA Test Results Summary${NC}"
echo "=================================================="
echo -e "Total Tests: ${TOTAL_TESTS}"
echo -e "${GREEN}Passed: ${PASSED_TESTS}${NC}"
echo -e "${RED}Failed: ${FAILED_TESTS}${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 All QA tests passed! Ready for App Store submission.${NC}"
    echo ""
    echo -e "${BLUE}📋 Pre-submission Checklist:${NC}"
    echo "□ All tests passing ✅"
    echo "□ App icons prepared"
    echo "□ Screenshots generated"
    echo "□ Privacy policy created"
    echo "□ Code signing configured"
    echo "□ Release build tested"
    echo ""
    echo -e "${BLUE}🚀 Next Steps:${NC}"
    echo "1. Run ./Scripts/build_release.sh to create App Store build"
    echo "2. Test IPA on physical device"
    echo "3. Upload to App Store Connect"
    echo "4. Submit for review"
    
    exit 0
else
    echo ""
    echo -e "${RED}❌ ${FAILED_TESTS} test(s) failed. Please fix issues before submission.${NC}"
    echo ""
    echo -e "${YELLOW}🔧 Troubleshooting:${NC}"
    echo "1. Check test logs for specific failure details"
    echo "2. Run individual test suites to isolate issues"
    echo "3. Verify all dependencies are properly configured"
    echo "4. Ensure code signing is set up correctly"
    
    exit 1
fi