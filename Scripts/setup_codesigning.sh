#!/bin/bash

# Code Signing Setup Script for Geo Sonar Hunt
# This script helps set up code signing certificates and provisioning profiles

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔐 Code Signing Setup for Geo Sonar Hunt${NC}"
echo "=============================================="

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if logged into Xcode
echo -e "${BLUE}👤 Checking Xcode account status...${NC}"
XCODE_ACCOUNT=$(xcrun xcodebuild -showBuildSettings 2>/dev/null | grep DEVELOPMENT_TEAM || echo "")

if [ -z "$XCODE_ACCOUNT" ]; then
    print_warning "No development team found in Xcode"
    echo ""
    echo "Please complete the following steps:"
    echo "1. Open Xcode"
    echo "2. Go to Xcode > Preferences > Accounts"
    echo "3. Add your Apple ID"
    echo "4. Select your team"
    echo ""
    read -p "Press Enter after completing these steps..."
fi

# Display current certificates
echo -e "${BLUE}📜 Available certificates:${NC}"
security find-identity -v -p codesigning | grep "iPhone"

echo ""
echo -e "${BLUE}📱 Available provisioning profiles:${NC}"
ls -la ~/Library/MobileDevice/Provisioning\ Profiles/ 2>/dev/null || echo "No provisioning profiles found"

echo ""
print_info "Code signing setup checklist:"
echo ""
echo "For Development:"
echo "□ iOS Development certificate installed"
echo "□ Development provisioning profile for com.geosohunt.app"
echo ""
echo "For App Store Distribution:"
echo "□ iOS Distribution certificate installed"
echo "□ App Store provisioning profile for com.geosohunt.app"
echo ""
echo "Environment Variables to Set:"
echo "□ DEVELOPMENT_TEAM_ID (your 10-character team ID)"
echo "□ APP_PROVISIONING_PROFILE_DEBUG (development profile name)"
echo "□ APP_PROVISIONING_PROFILE_RELEASE (distribution profile name)"
echo ""

# Create environment template
echo -e "${BLUE}📝 Creating environment template...${NC}"
cat > .env.template << EOF
# Code Signing Environment Variables
# Copy this file to .env and fill in your values

# Your Apple Developer Team ID (10 characters)
DEVELOPMENT_TEAM_ID=XXXXXXXXXX

# Provisioning Profile Names
APP_PROVISIONING_PROFILE_DEBUG="Geo Sonar Hunt Development"
APP_PROVISIONING_PROFILE_RELEASE="Geo Sonar Hunt App Store"

# Optional: Apple ID for automated uploads
APPLE_ID=your.email@example.com
APP_SPECIFIC_PASSWORD=xxxx-xxxx-xxxx-xxxx
EOF

print_status "Environment template created at .env.template"

echo ""
print_info "Next steps:"
echo "1. Copy .env.template to .env"
echo "2. Fill in your team ID and provisioning profile names"
echo "3. Create provisioning profiles in Apple Developer Portal"
echo "4. Download and install certificates and profiles"
echo "5. Run the build script: ./Scripts/build_release.sh"
echo ""

# Check if fastlane is available for easier certificate management
if command -v fastlane &> /dev/null; then
    print_info "Fastlane detected! You can use 'fastlane match' for easier certificate management"
else
    print_info "Consider installing Fastlane for easier certificate management: gem install fastlane"
fi