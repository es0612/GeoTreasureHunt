import Testing
import Foundation
@testable import GeoSonarCore

@Suite("ErrorHandler Tests")
struct ErrorHandlerTests {
    
    @Test("ErrorHandler handles errors and updates state")
    @MainActor
    func testErrorHandlerHandlesErrors() async {
        let errorHandler = ErrorHandler()
        let error = GameError.gpsSignalWeak
        
        await errorHandler.handle(error)
        
        #expect(errorHandler.currentError == error)
        #expect(errorHandler.isShowingError == true)
        #expect(errorHandler.errorHistory.count == 1)
        #expect(errorHandler.errorHistory.first?.error == error)
    }
    
    @Test("ErrorHandler attempts automatic recovery for recoverable errors")
    @MainActor
    func testErrorHandlerAttemptsRecovery() async {
        let errorHandler = ErrorHandler()
        let recoverableError = GameError.gpsSignalWeak
        let nonRecoverableError = GameError.compassUnavailable
        
        await errorHandler.handle(recoverableError)
        #expect(errorHandler.recoveryAttempts[recoverableError.id] == 1)
        
        await errorHandler.handle(nonRecoverableError)
        #expect(errorHandler.recoveryAttempts[nonRecoverableError.id] == nil)
    }
    
    @Test("ErrorHandler limits recovery attempts")
    @MainActor
    func testErrorHandlerLimitsRecoveryAttempts() async {
        let errorHandler = ErrorHandler()
        let error = GameError.gpsSignalWeak
        
        // Attempt recovery multiple times
        for _ in 0..<5 {
            await errorHandler.handle(error)
        }
        
        #expect(errorHandler.recoveryAttempts[error.id] == 3) // Max attempts should be 3
        #expect(errorHandler.hasExceededMaxRetries(for: error) == true)
    }
    
    @Test("ErrorHandler clears errors")
    @MainActor
    func testErrorHandlerClearsErrors() async {
        let errorHandler = ErrorHandler()
        let error = GameError.mapDataCorrupted
        
        await errorHandler.handle(error)
        #expect(errorHandler.isShowingError == true)
        
        await errorHandler.clearError()
        #expect(errorHandler.currentError == nil)
        #expect(errorHandler.isShowingError == false)
    }
    
    @Test("ErrorHandler provides graceful degradation options")
    func testErrorHandlerGracefulDegradation() async {
        let errorHandler = ErrorHandler()
        
        let degradationOptions = await errorHandler.getDegradationOptions(for: .compassUnavailable)
        #expect(degradationOptions.contains(.disableDowsingMode))
        #expect(degradationOptions.contains(.showSonarModeOnly))
        
        let audioOptions = await errorHandler.getDegradationOptions(for: .audioServiceUnavailable)
        #expect(audioOptions.contains(.useVisualFeedbackOnly))
        #expect(audioOptions.contains(.useHapticFeedbackOnly))
    }
    
    @Test("ErrorHandler logs errors for analysis")
    @MainActor
    func testErrorHandlerLogsErrors() async {
        let errorHandler = ErrorHandler()
        let error = GameError.locationPermissionDenied
        
        await errorHandler.handle(error)
        
        let logEntry = errorHandler.errorHistory.first
        #expect(logEntry?.error == error)
        #expect(logEntry?.timestamp != nil)
        #expect(logEntry?.context != nil)
    }
    
    @Test("ErrorHandler provides fallback mechanisms")
    func testErrorHandlerFallbackMechanisms() async {
        let errorHandler = ErrorHandler()
        
        // Test GPS fallback
        let gpsFallback = await errorHandler.getFallbackMechanism(for: .gpsSignalWeak)
        #expect(gpsFallback == .useLastKnownLocation)
        
        // Test map data fallback
        let mapFallback = await errorHandler.getFallbackMechanism(for: .mapDataCorrupted)
        #expect(mapFallback == .useDefaultMap)
        
        // Test treasure data fallback
        let treasureFallback = await errorHandler.getFallbackMechanism(for: .treasureDataMissing)
        #expect(treasureFallback == .useHardcodedTreasures)
    }
}