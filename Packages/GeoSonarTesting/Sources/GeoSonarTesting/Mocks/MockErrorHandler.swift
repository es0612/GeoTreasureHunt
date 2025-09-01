import Foundation
import GeoSonarCore

/// Mock implementation of ErrorHandler for testing purposes
@available(iOS 17.0, macOS 14.0, *)
@Observable
public class MockErrorHandler: ErrorHandler {
    
    // MARK: - Mock Properties
    
    public var handleCallCount = 0
    public var clearErrorCallCount = 0
    public var lastHandledError: GameError?
    public var shouldSimulateRecovery = false
    public var simulatedDegradationOptions: [GameError: [DegradationOption]] = [:]
    public var simulatedFallbackMechanisms: [GameError: FallbackMechanism?] = [:]
    
    // MARK: - Initialization
    
    public override init() {
        super.init()
    }
    
    // MARK: - Override Methods
    
    @MainActor
    public override func handle(_ error: GameError) async {
        handleCallCount += 1
        lastHandledError = error
        
        if shouldSimulateRecovery {
            await super.handle(error)
        } else {
            // Simplified mock behavior
            currentError = error
            isShowingError = true
            
            let logEntry = ErrorLogEntry(
                error: error,
                timestamp: Date(),
                context: [:],
                recoveryAttempted: error.isRecoverable
            )
            errorHistory.append(logEntry)
        }
    }
    
    @MainActor
    public override func clearError() async {
        clearErrorCallCount += 1
        await super.clearError()
    }
    
    public override func getDegradationOptions(for error: GameError) async -> [DegradationOption] {
        if let mockOptions = simulatedDegradationOptions[error] {
            return mockOptions
        }
        return await super.getDegradationOptions(for: error)
    }
    
    public override func getFallbackMechanism(for error: GameError) async -> FallbackMechanism? {
        if let mockMechanism = simulatedFallbackMechanisms[error] {
            return mockMechanism
        }
        return await super.getFallbackMechanism(for: error)
    }
    
    // MARK: - Mock Helper Methods
    
    /// Reset all mock state
    @MainActor
    public func reset() {
        handleCallCount = 0
        clearErrorCallCount = 0
        lastHandledError = nil
        shouldSimulateRecovery = false
        simulatedDegradationOptions.removeAll()
        simulatedFallbackMechanisms.removeAll()
        
        // Reset parent state
        currentError = nil
        isShowingError = false
        errorHistory.removeAll()
        recoveryAttempts.removeAll()
    }
    
    /// Simulate a specific degradation option for testing
    public func simulateDegradationOptions(_ options: [DegradationOption], for error: GameError) {
        simulatedDegradationOptions[error] = options
    }
    
    /// Simulate a specific fallback mechanism for testing
    public func simulateFallbackMechanism(_ mechanism: FallbackMechanism?, for error: GameError) {
        simulatedFallbackMechanisms[error] = mechanism
    }
    
    /// Simulate exceeding max retry attempts
    public func simulateMaxRetriesExceeded(for error: GameError) {
        recoveryAttempts[error.id] = 999 // Exceed max attempts
    }
}