# Geo Sonar Hunt

A GPS-based treasure hunting game for iOS built with Swift 6, SwiftUI, and modern development practices.

## Project Structure

This project uses a modular architecture with Swift Package Manager (SPM) local packages:

- **GeoSonarCore**: Core business logic and models
- **GeoSonarUI**: UI components and ViewModels  
- **GeoSonarTesting**: Test utilities and mocks
- **GeoSonarHuntApp**: Main iOS application target

## Requirements

- Xcode 15.0+
- iOS 15.0+
- Swift 6.0
- XcodeGen

## Setup

1. Install XcodeGen:
   ```bash
   brew install xcodegen
   ```

2. Generate the Xcode project:
   ```bash
   xcodegen generate
   ```

3. Open the generated project:
   ```bash
   open GeoSonarHunt.xcodeproj
   ```

## Development

### Running Tests

Run tests for individual packages:
```bash
# Core package tests
cd Packages/GeoSonarCore && swift test

# UI package tests  
cd Packages/GeoSonarUI && swift test

# Testing utilities tests
cd Packages/GeoSonarTesting && swift test
```

Run all tests from Xcode using the test scheme.

### Code Quality

This project uses SwiftLint for code quality. Install it with:
```bash
brew install swiftlint
```

Run linting:
```bash
swiftlint lint
```

### Swift 6 Features

This project leverages Swift 6 features including:
- Strict concurrency checking
- @Observable macro for state management
- Swift Testing framework
- Typed throws

## Architecture

The app follows MVVM pattern with Repository pattern for data access:
- **Models**: Data structures and business entities
- **Repositories**: Data access layer with protocol-based design
- **Services**: Business logic and external integrations
- **ViewModels**: UI state management with @Observable
- **Views**: SwiftUI declarative UI components

## CI/CD

GitHub Actions workflow automatically:
- Runs tests on all packages
- Builds the main application
- Performs code quality checks with SwiftLint
- Supports both main and develop branch workflows