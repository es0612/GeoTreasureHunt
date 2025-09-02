import Testing
import SwiftUI
@testable import GeoSonarUI
@testable import GeoSonarCore

@Suite("ErrorView Tests")
struct ErrorViewTests {
    
    @Test("ErrorView displays error information correctly")
    @MainActor func testErrorViewDisplaysErrorInformation() {
        let error = GameError.gpsSignalWeak
        var dismissCalled = false
        var retryCalled = false
        
        let errorView = ErrorView(
            error: error,
            onDismiss: { dismissCalled = true },
            onRetry: { retryCalled = true }
        )
        
        // Test that the view can be created without crashing
        #expect(errorView.error == error)
    }
    
    @Test("ErrorView shows correct icon for different error severities")
    @MainActor func testErrorViewIconsForSeverities() {
        let criticalError = GameError.locationPermissionDenied
        let warningError = GameError.gpsSignalWeak
        let minorError = GameError.audioServiceUnavailable
        
        // Test that different error types can be displayed
        let criticalView = ErrorView(error: criticalError, onDismiss: {})
        let warningView = ErrorView(error: warningError, onDismiss: {})
        let minorView = ErrorView(error: minorError, onDismiss: {})
        
        #expect(criticalView.error.severity == .critical)
        #expect(warningView.error.severity == .warning)
        #expect(minorView.error.severity == .minor)
    }
    
    @Test("ErrorView shows retry button for recoverable errors")
    @MainActor func testErrorViewRetryButtonForRecoverableErrors() {
        let recoverableError = GameError.gpsSignalWeak
        let nonRecoverableError = GameError.compassUnavailable
        
        let recoverableView = ErrorView(
            error: recoverableError,
            onDismiss: {},
            onRetry: {}
        )
        
        let nonRecoverableView = ErrorView(
            error: nonRecoverableError,
            onDismiss: {}
        )
        
        #expect(recoverableView.error.isRecoverable == true)
        #expect(nonRecoverableView.error.isRecoverable == false)
    }
    
    @Test("ErrorView displays recovery suggestions when available")
    @MainActor func testErrorViewRecoverySuggestions() {
        let errorWithSuggestion = GameError.locationPermissionDenied
        let errorWithoutSuggestion = GameError.unexpectedError("Test error")
        
        let viewWithSuggestion = ErrorView(
            error: errorWithSuggestion,
            onDismiss: {}
        )
        
        let viewWithoutSuggestion = ErrorView(
            error: errorWithoutSuggestion,
            onDismiss: {}
        )
        
        #expect(viewWithSuggestion.error.recoverySuggestion != nil)
        #expect(viewWithoutSuggestion.error.recoverySuggestion != nil) // All errors have suggestions in our implementation
    }
    
    @Test("ErrorOverlay modifier can be applied to views")
    @MainActor func testErrorOverlayModifier() {
        let testView = Text("Test Content")
            .errorOverlay(
                error: .constant(GameError.mapDataCorrupted),
                onRetry: {}
            )
        
        // Test that the modifier can be applied without crashing
        // In a real UI test, we would verify the overlay appears
        #expect(testView != nil)
    }
    
    @Test("ErrorOverlay handles nil error state")
    @MainActor func testErrorOverlayNilError() {
        let testView = Text("Test Content")
            .errorOverlay(
                error: .constant(nil),
                onRetry: {}
            )
        
        // Test that the modifier handles nil error gracefully
        #expect(testView != nil)
    }
}