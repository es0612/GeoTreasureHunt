import Foundation
import OSLog

/// Error log entry for tracking and analysis
public struct ErrorLogEntry: Equatable {
    public let error: GameError
    public let timestamp: Date
    public let context: [String: String]
    public let recoveryAttempted: Bool
    
    public init(error: GameError, timestamp: Date = Date(), context: [String: String] = [:], recoveryAttempted: Bool = false) {
        self.error = error
        self.timestamp = timestamp
        self.context = context
        self.recoveryAttempted = recoveryAttempted
    }
}

/// Comprehensive error handler for the Geo Sonar Hunt game
@available(iOS 17.0, macOS 14.0, *)
@Observable
open class ErrorHandler {
    
    // MARK: - Public Properties
    
    /// Current error being displayed to the user
    public var currentError: GameError?
    
    /// Whether an error is currently being shown
    public var isShowingError: Bool = false
    
    /// History of all errors for analysis
    public var errorHistory: [ErrorLogEntry] = []
    
    /// Recovery attempts count for each error type
    public var recoveryAttempts: [String: Int] = [:]
    
    // MARK: - Private Properties
    
    private let logger: Logger? = {
        if #available(iOS 14.0, macOS 11.0, *) {
            return Logger(subsystem: "com.geosohunt.GeoSonarCore", category: "ErrorHandler")
        } else {
            return nil
        }
    }()
    private let maxRecoveryAttempts = 3
    private let recoveryTimeoutInterval: TimeInterval = 30.0
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - Public Methods
    
    /// Handle an error with automatic recovery attempts and logging
    @MainActor
    open func handle(_ error: GameError) async {
        if #available(iOS 14.0, macOS 11.0, *) {
            logger?.error("Handling error: \(error.id) - \(error.errorDescription ?? "Unknown error")")
        }
        
        // Update current error state
        currentError = error
        isShowingError = true
        
        // Log the error
        logError(error)
        
        // Attempt recovery if the error is recoverable
        if error.isRecoverable && !hasExceededMaxRetries(for: error) {
            await attemptRecovery(for: error)
        }
    }
    
    /// Clear the current error
    @MainActor
    open func clearError() async {
        if #available(iOS 14.0, macOS 11.0, *) {
            logger?.info("Clearing current error")
        }
        currentError = nil
        isShowingError = false
    }
    
    /// Check if recovery attempts have been exceeded for an error
    public func hasExceededMaxRetries(for error: GameError) -> Bool {
        let attempts = recoveryAttempts[error.id] ?? 0
        return attempts >= maxRecoveryAttempts
    }
    
    /// Get degradation options for graceful error handling
    open func getDegradationOptions(for error: GameError) async -> [DegradationOption] {
        switch error {
        case .compassUnavailable:
            return [.disableDowsingMode, .showSonarModeOnly]
        case .audioServiceUnavailable:
            return [.useVisualFeedbackOnly, .useHapticFeedbackOnly, .disableAudio]
        case .hapticServiceUnavailable:
            return [.useVisualFeedbackOnly, .disableHaptics]
        case .gpsSignalWeak:
            return [.useLastKnownLocation]
        case .mapDataCorrupted:
            return [.useDefaultMap]
        case .locationPermissionDenied, .locationServiceUnavailable:
            return [] // Critical errors don't have degradation options
        case .treasureDataMissing:
            return [.useDefaultMap]
        case .networkUnavailable:
            return [] // App works offline
        case .dataCorruption, .unexpectedError:
            return [.useDefaultMap]
        }
    }
    
    /// Get fallback mechanism for error recovery
    open func getFallbackMechanism(for error: GameError) async -> FallbackMechanism? {
        switch error {
        case .gpsSignalWeak:
            return .useLastKnownLocation
        case .mapDataCorrupted:
            return .useDefaultMap
        case .treasureDataMissing:
            return .useHardcodedTreasures
        case .compassUnavailable:
            return .switchToSonarMode
        case .audioServiceUnavailable:
            return .disableAudioFeedback
        case .hapticServiceUnavailable:
            return .disableHapticFeedback
        case .locationPermissionDenied, .locationServiceUnavailable:
            return .showErrorMessage
        case .networkUnavailable:
            return nil // No fallback needed for offline operation
        case .dataCorruption, .unexpectedError:
            return .useDefaultMap
        }
    }
    
    /// Reset recovery attempts for an error type
    public func resetRecoveryAttempts(for error: GameError) {
        recoveryAttempts[error.id] = 0
    }
    
    /// Get error statistics for analysis
    public func getErrorStatistics() -> [String: Any] {
        let errorCounts = Dictionary(grouping: errorHistory, by: { $0.error.id })
            .mapValues { $0.count }
        
        let severityCounts = Dictionary(grouping: errorHistory, by: { $0.error.severity.rawValue })
            .mapValues { $0.count }
        
        return [
            "totalErrors": errorHistory.count,
            "errorCounts": errorCounts,
            "severityCounts": severityCounts,
            "recoveryAttempts": recoveryAttempts
        ]
    }
    
    // MARK: - Private Methods
    
    /// Log an error for tracking and analysis
    private func logError(_ error: GameError, context: [String: String] = [:]) {
        let logEntry = ErrorLogEntry(
            error: error,
            timestamp: Date(),
            context: context,
            recoveryAttempted: error.isRecoverable
        )
        
        errorHistory.append(logEntry)
        
        // Log to system logger
        if #available(iOS 14.0, macOS 11.0, *) {
            logger?.error("Error logged: \(error.id), Severity: \(error.severity.rawValue), Recoverable: \(error.isRecoverable)")
        }
        
        // Keep only last 100 error entries to prevent memory issues
        if errorHistory.count > 100 {
            errorHistory.removeFirst(errorHistory.count - 100)
        }
    }
    
    /// Attempt automatic recovery for recoverable errors
    @MainActor
    private func attemptRecovery(for error: GameError) async {
        guard error.isRecoverable else { return }
        
        let currentAttempts = recoveryAttempts[error.id] ?? 0
        guard currentAttempts < maxRecoveryAttempts else { return }
        
        // Increment recovery attempts
        recoveryAttempts[error.id] = currentAttempts + 1
        
        if #available(iOS 14.0, macOS 11.0, *) {
            logger?.info("Attempting recovery for error: \(error.id), Attempt: \(currentAttempts + 1)")
        }
        
        switch error {
        case .gpsSignalWeak:
            await attemptGPSRecovery()
        case .mapDataCorrupted:
            await attemptMapDataRecovery()
        case .audioServiceUnavailable:
            await attemptAudioServiceRecovery()
        case .hapticServiceUnavailable:
            await attemptHapticServiceRecovery()
        case .dataCorruption:
            await attemptDataRecovery()
        default:
            if #available(iOS 14.0, macOS 11.0, *) {
                logger?.info("No specific recovery mechanism for error: \(error.id)")
            }
        }
    }
    
    /// Attempt GPS signal recovery
    @MainActor
    private func attemptGPSRecovery() async {
        if #available(iOS 14.0, macOS 11.0, *) {
            logger?.info("Attempting GPS recovery")
        }
        // Implementation would involve requesting higher accuracy, 
        // checking location services status, etc.
        // For now, we'll simulate a recovery attempt
        if #available(iOS 13.0, macOS 10.15, *) {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        }
    }
    
    /// Attempt map data recovery
    @MainActor
    private func attemptMapDataRecovery() async {
        if #available(iOS 14.0, macOS 11.0, *) {
            logger?.info("Attempting map data recovery")
        }
        // Implementation would involve reloading map data,
        // falling back to default maps, etc.
        if #available(iOS 13.0, macOS 10.15, *) {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        }
    }
    
    /// Attempt audio service recovery
    @MainActor
    private func attemptAudioServiceRecovery() async {
        if #available(iOS 14.0, macOS 11.0, *) {
            logger?.info("Attempting audio service recovery")
        }
        // Implementation would involve reinitializing audio session,
        // checking audio permissions, etc.
        if #available(iOS 13.0, macOS 10.15, *) {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        }
    }
    
    /// Attempt haptic service recovery
    @MainActor
    private func attemptHapticServiceRecovery() async {
        if #available(iOS 14.0, macOS 11.0, *) {
            logger?.info("Attempting haptic service recovery")
        }
        // Implementation would involve checking haptic capabilities,
        // reinitializing haptic engine, etc.
        if #available(iOS 13.0, macOS 10.15, *) {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        }
    }
    
    /// Attempt data recovery
    @MainActor
    private func attemptDataRecovery() async {
        if #available(iOS 14.0, macOS 11.0, *) {
            logger?.info("Attempting data recovery")
        }
        // Implementation would involve clearing corrupted data,
        // restoring from backup, resetting to defaults, etc.
        if #available(iOS 13.0, macOS 10.15, *) {
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        }
    }
}