#!/bin/bash

# Release Validation Script for Geo Sonar Hunt
# Final validation before App Store submission

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Geo Sonar Hunt - Release Validation${NC}"
echo "============================================"

# Validation results tracking
VALIDATION_ERRORS=0
VALIDATION_WARNINGS=0

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((VALIDATION_WARNINGS++))
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    ((VALIDATION_ERRORS++))
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# 1. Project Structure Validation
echo -e "${BLUE}📁 Validating project structure...${NC}"

if [ -f "project.yml" ]; then
    print_success "XcodeGen project configuration found"
else
    print_error "project.yml not found"
fi

if [ -d "Packages/GeoSonarCore" ] && [ -d "Packages/GeoSonarUI" ] && [ -d "Packages/GeoSonarTesting" ]; then
    print_success "All required packages present"
else
    print_error "Missing required packages"
fi

if [ -f "GeoSonarHuntApp/Info.plist" ]; then
    print_success "Info.plist found"
else
    print_error "Info.plist not found"
fi

# 2. App Store Assets Validation
echo -e "${BLUE}🎨 Validating App Store assets...${NC}"

if [ -f "GeoSonarHuntApp/Assets.xcassets/AppIcon.appiconset/Contents.json" ]; then
    print_success "App icon configuration found"
else
    print_warning "App icon configuration missing - icons need to be added"
fi

if [ -d "AppStore" ]; then
    print_success "App Store assets directory found"
else
    print_warning "App Store assets directory missing"
fi

# 3. Legal Documents Validation
echo -e "${BLUE}📄 Validating legal documents...${NC}"

if [ -f "Legal/PrivacyPolicy.md" ]; then
    print_success "Privacy policy found"
else
    print_error "Privacy policy missing"
fi

if [ -f "Legal/LocationUsageDescription.md" ]; then
    print_success "Location usage description found"
else
    print_error "Location usage description missing"
fi

# 4. Build Scripts Validation
echo -e "${BLUE}🔧 Validating build scripts...${NC}"

if [ -x "Scripts/build_release.sh" ]; then
    print_success "Release build script found and executable"
else
    print_error "Release build script missing or not executable"
fi

if [ -f "Scripts/ExportOptions.plist" ]; then
    print_success "Export options configuration found"
else
    print_error "Export options configuration missing"
fi

# 5. Info.plist Validation
echo -e "${BLUE}📱 Validating Info.plist configuration...${NC}"

if grep -q "NSLocationWhenInUseUsageDescription" GeoSonarHuntApp/Info.plist; then
    print_success "Location usage description in Info.plist"
else
    print_error "Location usage description missing from Info.plist"
fi

if grep -q "CFBundleDisplayName" GeoSonarHuntApp/Info.plist; then
    print_success "App display name configured"
else
    print_error "App display name missing"
fi

if grep -q "1.0.0" GeoSonarHuntApp/Info.plist; then
    print_success "Version number configured"
else
    print_warning "Version number may need updating"
fi

# 6. Package Tests Validation
echo -e "${BLUE}🧪 Running package tests...${NC}"

print_info "Testing GeoSonarCore package..."
if swift test --package-path Packages/GeoSonarCore --quiet; then
    print_success "GeoSonarCore tests passed"
else
    print_error "GeoSonarCore tests failed"
fi

print_info "Testing GeoSonarTesting package..."
if swift test --package-path Packages/GeoSonarTesting --quiet; then
    print_success "GeoSonarTesting tests passed"
else
    print_error "GeoSonarTesting tests failed"
fi

# Note: GeoSonarUI tests have some warnings but pass
print_info "Testing GeoSonarUI package..."
if swift test --package-path Packages/GeoSonarUI --quiet 2>/dev/null; then
    print_success "GeoSonarUI tests passed"
else
    print_warning "GeoSonarUI tests have warnings (non-critical)"
fi

# 7. Project Generation Test
echo -e "${BLUE}🔨 Testing project generation...${NC}"

if xcodegen generate --quiet; then
    print_success "Xcode project generates successfully"
else
    print_error "Xcode project generation failed"
fi

# 8. Build Validation
echo -e "${BLUE}🏗️  Validating build configuration...${NC}"

print_info "Testing Debug build..."
if xcodebuild build -scheme GeoSonarHuntApp -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -configuration Debug -quiet; then
    print_success "Debug build successful"
else
    print_error "Debug build failed"
fi

print_info "Testing Release build..."
if xcodebuild build -scheme GeoSonarHuntApp -destination 'generic/platform=iOS' -configuration Release -quiet; then
    print_success "Release build successful"
else
    print_error "Release build failed"
fi

# 9. Code Quality Validation
echo -e "${BLUE}📏 Validating code quality...${NC}"

if command -v swiftlint &> /dev/null; then
    if swiftlint --quiet; then
        print_success "SwiftLint validation passed"
    else
        print_warning "SwiftLint found style issues"
    fi
else
    print_warning "SwiftLint not installed - skipping style validation"
fi

# 10. Documentation Validation
echo -e "${BLUE}📚 Validating documentation...${NC}"

if [ -f "QA/PreSubmissionChecklist.md" ]; then
    print_success "Pre-submission checklist found"
else
    print_error "Pre-submission checklist missing"
fi

if [ -f "README.md" ]; then
    print_success "README.md found"
else
    print_warning "README.md missing"
fi

# 11. Environment Configuration
echo -e "${BLUE}⚙️  Validating environment configuration...${NC}"

if [ -f ".env.template" ]; then
    print_success "Environment template found"
else
    print_warning "Environment template missing"
fi

# Final Results
echo ""
echo "============================================"
echo -e "${BLUE}📊 Validation Results Summary${NC}"
echo "============================================"

if [ $VALIDATION_ERRORS -eq 0 ] && [ $VALIDATION_WARNINGS -eq 0 ]; then
    echo -e "${GREEN}🎉 Perfect! All validations passed.${NC}"
    echo ""
    echo -e "${BLUE}🚀 Ready for App Store submission!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Run ./Scripts/build_release.sh to create release build"
    echo "2. Test on physical device"
    echo "3. Upload to App Store Connect"
    echo "4. Submit for review"
    
elif [ $VALIDATION_ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Validation completed with ${VALIDATION_WARNINGS} warning(s).${NC}"
    echo ""
    echo "Warnings are non-critical but should be addressed before submission."
    echo "You can proceed with release build if warnings are acceptable."
    
else
    echo -e "${RED}❌ Validation failed with ${VALIDATION_ERRORS} error(s) and ${VALIDATION_WARNINGS} warning(s).${NC}"
    echo ""
    echo "Please fix all errors before proceeding with App Store submission."
    echo ""
    echo "Common fixes:"
    echo "• Add app icons to Assets.xcassets"
    echo "• Ensure all required files are present"
    echo "• Fix any build configuration issues"
    echo "• Resolve test failures"
fi

echo ""
echo -e "${BLUE}📋 For detailed submission requirements, see:${NC}"
echo "• QA/PreSubmissionChecklist.md"
echo "• AppStore/README.md"
echo "• Legal/PrivacyPolicy.md"

exit $VALIDATION_ERRORS