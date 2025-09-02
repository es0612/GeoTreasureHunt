#!/bin/bash

# Geo Sonar Hunt - Release Build Script
# This script automates the process of building and archiving the app for App Store submission

set -e  # Exit on any error

# Configuration
SCHEME_NAME="GeoSonarHuntApp"
WORKSPACE_NAME="GeoSonarHunt.xcworkspace"
ARCHIVE_PATH="./Build/Archives/GeoSonarHunt.xcarchive"
EXPORT_PATH="./Build/Export"
EXPORT_OPTIONS_PLIST="./Scripts/ExportOptions.plist"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting Geo Sonar Hunt Release Build Process${NC}"
echo "=================================================="

# Function to print status
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check prerequisites
echo -e "${BLUE}📋 Checking prerequisites...${NC}"

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    print_error "Xcode command line tools not found. Please install Xcode."
    exit 1
fi

# Check if XcodeGen is installed
if ! command -v xcodegen &> /dev/null; then
    print_error "XcodeGen not found. Please install with: brew install xcodegen"
    exit 1
fi

print_status "Prerequisites check completed"

# Generate Xcode project
echo -e "${BLUE}🔧 Generating Xcode project with XcodeGen...${NC}"
xcodegen generate
print_status "Xcode project generated"

# Clean previous builds
echo -e "${BLUE}🧹 Cleaning previous builds...${NC}"
rm -rf ./Build
mkdir -p ./Build/Archives
mkdir -p ./Build/Export
print_status "Build directories cleaned and created"

# Run tests before building
echo -e "${BLUE}🧪 Running tests before release build...${NC}"
xcodebuild test \
    -scheme "$SCHEME_NAME" \
    -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
    -configuration Release \
    -quiet

if [ $? -eq 0 ]; then
    print_status "All tests passed"
else
    print_error "Tests failed. Aborting release build."
    exit 1
fi

# Build and archive
echo -e "${BLUE}📦 Building and archiving for release...${NC}"
xcodebuild archive \
    -scheme "$SCHEME_NAME" \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    -destination 'generic/platform=iOS' \
    -quiet

if [ $? -eq 0 ]; then
    print_status "Archive created successfully"
else
    print_error "Archive creation failed"
    exit 1
fi

# Export IPA
echo -e "${BLUE}📤 Exporting IPA for App Store submission...${NC}"
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" \
    -quiet

if [ $? -eq 0 ]; then
    print_status "IPA exported successfully"
else
    print_error "IPA export failed"
    exit 1
fi

# Validate the archive
echo -e "${BLUE}✅ Validating archive...${NC}"
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "./Build/Validation" \
    -exportOptionsPlist "./Scripts/ValidationOptions.plist" \
    -quiet

if [ $? -eq 0 ]; then
    print_status "Archive validation completed"
else
    print_warning "Archive validation had warnings (check manually)"
fi

# Display build information
echo ""
echo -e "${GREEN}🎉 Release build completed successfully!${NC}"
echo "=================================================="
echo -e "${BLUE}📁 Build Artifacts:${NC}"
echo "   Archive: $ARCHIVE_PATH"
echo "   IPA: $EXPORT_PATH/GeoSonarHunt.ipa"
echo ""
echo -e "${BLUE}📋 Next Steps:${NC}"
echo "1. Test the IPA on a physical device"
echo "2. Upload to App Store Connect using Xcode or Transporter"
echo "3. Submit for App Store review"
echo ""
echo -e "${YELLOW}💡 Upload Command:${NC}"
echo "   xcrun altool --upload-app --type ios --file \"$EXPORT_PATH/GeoSonarHunt.ipa\" --username \"YOUR_APPLE_ID\" --password \"APP_SPECIFIC_PASSWORD\""
echo ""