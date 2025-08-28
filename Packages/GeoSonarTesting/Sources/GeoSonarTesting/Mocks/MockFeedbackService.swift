import Foundation
import GeoSonarCore

/// Mock implementation of FeedbackServiceProtocol for testing purposes
public final class MockFeedbackService: FeedbackServiceProtocol, @unchecked Sendable {
    
    // MARK: - Mock State
    
    public var mockFeedbackIntensity: FeedbackIntensity = .medium
    public var mockAudioVolume: Float = 0.5
    public var mockHapticIntensity: Float = 0.5
    public var mockPulseAnimationSettings: PulseAnimationSettings = PulseAnimationSettings(frequency: 1.0, amplitude: 0.5, duration: 0.3)
    public var mockPulseColor: FeedbackColor = .mediumSonar
    public var mockSonarFeedbackSuccess: Bool = true
    public var mockHapticFeedbackSuccess: Bool = true
    public var mockAudioFeedbackSuccess: Bool = true
    
    // MARK: - Call Tracking
    
    public private(set) var calculateFeedbackIntensityCalls: [Double] = []
    public private(set) var calculateAudioVolumeCalls: [(FeedbackIntensity, GameSettings)] = []
    public private(set) var calculateHapticIntensityCalls: [(FeedbackIntensity, GameSettings)] = []
    public private(set) var calculatePulseAnimationSettingsCalls: [FeedbackIntensity] = []
    public private(set) var calculatePulseColorCalls: [FeedbackIntensity] = []
    public private(set) var provideSonarFeedbackCalls: [(Double, GameSettings)] = []
    public private(set) var provideHapticFeedbackCalls: [Float] = []
    public private(set) var playAudioFeedbackCalls: [Float] = []
    
    public init() {}
    
    // MARK: - FeedbackServiceProtocol Implementation
    
    public func calculateFeedbackIntensity(for distance: Double) -> FeedbackIntensity {
        calculateFeedbackIntensityCalls.append(distance)
        return mockFeedbackIntensity
    }
    
    public func calculateAudioVolume(intensity: FeedbackIntensity, settings: GameSettings) -> Float {
        calculateAudioVolumeCalls.append((intensity, settings))
        return mockAudioVolume
    }
    
    public func calculateHapticIntensity(intensity: FeedbackIntensity, settings: GameSettings) -> Float {
        calculateHapticIntensityCalls.append((intensity, settings))
        return mockHapticIntensity
    }
    
    public func calculatePulseAnimationSettings(intensity: FeedbackIntensity) -> PulseAnimationSettings {
        calculatePulseAnimationSettingsCalls.append(intensity)
        return mockPulseAnimationSettings
    }
    
    public func calculatePulseColor(intensity: FeedbackIntensity) -> FeedbackColor {
        calculatePulseColorCalls.append(intensity)
        return mockPulseColor
    }
    
    public func provideSonarFeedback(distance: Double, settings: GameSettings) async -> Bool {
        provideSonarFeedbackCalls.append((distance, settings))
        return mockSonarFeedbackSuccess
    }
    
    public func provideHapticFeedback(intensity: Float) async -> Bool {
        provideHapticFeedbackCalls.append(intensity)
        return mockHapticFeedbackSuccess
    }
    
    public func playAudioFeedback(volume: Float) async -> Bool {
        playAudioFeedbackCalls.append(volume)
        return mockAudioFeedbackSuccess
    }
    
    // MARK: - Test Utilities
    
    /// Resets all mock state and call tracking
    public func reset() {
        mockFeedbackIntensity = .medium
        mockAudioVolume = 0.5
        mockHapticIntensity = 0.5
        mockPulseAnimationSettings = PulseAnimationSettings(frequency: 1.0, amplitude: 0.5, duration: 0.3)
        mockPulseColor = .mediumSonar
        mockSonarFeedbackSuccess = true
        mockHapticFeedbackSuccess = true
        mockAudioFeedbackSuccess = true
        
        calculateFeedbackIntensityCalls.removeAll()
        calculateAudioVolumeCalls.removeAll()
        calculateHapticIntensityCalls.removeAll()
        calculatePulseAnimationSettingsCalls.removeAll()
        calculatePulseColorCalls.removeAll()
        provideSonarFeedbackCalls.removeAll()
        provideHapticFeedbackCalls.removeAll()
        playAudioFeedbackCalls.removeAll()
    }
    
    /// Sets up mock to simulate strong feedback scenario
    public func setupStrongFeedback() {
        mockFeedbackIntensity = .strong
        mockAudioVolume = 0.8
        mockHapticIntensity = 0.8
        mockPulseAnimationSettings = PulseAnimationSettings(frequency: 2.0, amplitude: 0.7, duration: 0.3)
        mockPulseColor = .strongSonar
    }
    
    /// Sets up mock to simulate weak feedback scenario
    public func setupWeakFeedback() {
        mockFeedbackIntensity = .weak
        mockAudioVolume = 0.2
        mockHapticIntensity = 0.2
        mockPulseAnimationSettings = PulseAnimationSettings(frequency: 0.5, amplitude: 0.3, duration: 0.5)
        mockPulseColor = .weakSonar
    }
    
    /// Sets up mock to simulate feedback failure
    public func setupFeedbackFailure() {
        mockSonarFeedbackSuccess = false
        mockHapticFeedbackSuccess = false
        mockAudioFeedbackSuccess = false
    }
}