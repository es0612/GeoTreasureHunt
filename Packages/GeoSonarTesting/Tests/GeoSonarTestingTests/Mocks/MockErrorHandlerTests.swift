import Testing
import Foundation
@testable import GeoSonarTesting
@testable import GeoSonarCore

@Suite("MockErrorHandler Tests")
struct MockErrorHandlerTests {
    
    @Test("MockErrorHandler tracks handle calls")
    @MainActor
    func testMockErrorHandlerTracksHandleCalls() async {
        let mockHandler = MockErrorHandler()
        let error = GameError.gpsSignalWeak
        
        await mockHandler.handle(error)
        
        #expect(mockHandler.handleCallCount == 1)
        #expect(mockHandler.lastHandledError == error)
        #expect(mockHandler.currentError == error)
        #expect(mockHandler.isShowingError == true)
    }
    
    @Test("MockErrorHandler tracks clear error calls")
    @MainActor
    func testMockErrorHandlerTracksClearErrorCalls() async {
        let mockHandler = MockErrorHandler()
        
        await mockHandler.clearError()
        
        #expect(mockHandler.clearErrorCallCount == 1)
        #expect(mockHandler.currentError == nil)
        #expect(mockHandler.isShowingError == false)
    }
    
    @Test("MockErrorHandler can simulate degradation options")
    func testMockErrorHandlerSimulatesDegradationOptions() async {
        let mockHandler = MockErrorHandler()
        let error = GameError.compassUnavailable
        let mockOptions: [DegradationOption] = [.disableDowsingMode, .showSonarModeOnly]
        
        mockHandler.simulateDegradationOptions(mockOptions, for: error)
        
        let options = await mockHandler.getDegradationOptions(for: error)
        #expect(options == mockOptions)
    }
    
    @Test("MockErrorHandler can simulate fallback mechanisms")
    func testMockErrorHandlerSimulatesFallbackMechanisms() async {
        let mockHandler = MockErrorHandler()
        let error = GameError.gpsSignalWeak
        let mockMechanism = FallbackMechanism.useLastKnownLocation
        
        mockHandler.simulateFallbackMechanism(mockMechanism, for: error)
        
        let mechanism = await mockHandler.getFallbackMechanism(for: error)
        #expect(mechanism == mockMechanism)
    }
    
    @Test("MockErrorHandler can simulate max retries exceeded")
    func testMockErrorHandlerSimulatesMaxRetriesExceeded() {
        let mockHandler = MockErrorHandler()
        let error = GameError.mapDataCorrupted
        
        mockHandler.simulateMaxRetriesExceeded(for: error)
        
        #expect(mockHandler.hasExceededMaxRetries(for: error) == true)
    }
    
    @Test("MockErrorHandler reset clears all state")
    @MainActor
    func testMockErrorHandlerResetClearsState() async {
        let mockHandler = MockErrorHandler()
        let error = GameError.audioServiceUnavailable
        
        // Set up some state
        await mockHandler.handle(error)
        await mockHandler.clearError()
        mockHandler.simulateDegradationOptions([DegradationOption.useVisualFeedbackOnly], for: error)
        
        // Reset
        await mockHandler.reset()
        
        #expect(mockHandler.handleCallCount == 0)
        #expect(mockHandler.clearErrorCallCount == 0)
        #expect(mockHandler.lastHandledError == nil)
        #expect(mockHandler.simulatedDegradationOptions.isEmpty)
        #expect(mockHandler.simulatedFallbackMechanisms.isEmpty)
    }
    
    @Test("MockErrorHandler can enable real recovery simulation")
    @MainActor
    func testMockErrorHandlerRealRecoverySimulation() async {
        let mockHandler = MockErrorHandler()
        let error = GameError.gpsSignalWeak
        
        mockHandler.shouldSimulateRecovery = true
        
        await mockHandler.handle(error)
        
        #expect(mockHandler.handleCallCount == 1)
        #expect(mockHandler.recoveryAttempts[error.id] == 1)
    }
}