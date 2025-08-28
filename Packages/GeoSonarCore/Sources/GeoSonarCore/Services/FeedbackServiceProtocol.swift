import Foundation
import AVFoundation
import CoreHaptics

/// Protocol defining the feedback service interface for providing audio, haptic, and visual feedback
public protocol FeedbackServiceProtocol: Sendable {
    
    /// Calculates the appropriate feedback intensity based on distance to treasure
    /// - Parameter distance: Distance to treasure in meters
    /// - Returns: Feedback intensity level
    func calculateFeedbackIntensity(for distance: Double) -> FeedbackIntensity
    
    /// Calculates the audio volume based on intensity and settings
    /// - Parameters:
    ///   - intensity: Feedback intensity level
    ///   - settings: Game settings including audio preferences
    /// - Returns: Audio volume (0.0 to 1.0)
    func calculateAudioVolume(intensity: FeedbackIntensity, settings: GameSettings) -> Float
    
    /// Calculates the haptic feedback intensity based on intensity and settings
    /// - Parameters:
    ///   - intensity: Feedback intensity level
    ///   - settings: Game settings including haptic preferences
    /// - Returns: Haptic intensity (0.0 to 1.0)
    func calculateHapticIntensity(intensity: FeedbackIntensity, settings: GameSettings) -> Float
    
    /// Calculates pulse animation settings for visual feedback
    /// - Parameter intensity: Feedback intensity level
    /// - Returns: Pulse animation settings
    func calculatePulseAnimationSettings(intensity: FeedbackIntensity) -> PulseAnimationSettings
    
    /// Calculates the color for pulse animation based on intensity
    /// - Parameter intensity: Feedback intensity level
    /// - Returns: Color for visual feedback
    func calculatePulseColor(intensity: FeedbackIntensity) -> FeedbackColor
    
    /// Provides complete sonar feedback (audio, haptic, and visual)
    /// - Parameters:
    ///   - distance: Distance to treasure in meters
    ///   - settings: Game settings
    /// - Returns: True if feedback was provided successfully
    func provideSonarFeedback(distance: Double, settings: GameSettings) async -> Bool
    
    /// Provides haptic feedback with specified intensity
    /// - Parameter intensity: Haptic intensity (0.0 to 1.0)
    /// - Returns: True if haptic feedback was provided successfully
    func provideHapticFeedback(intensity: Float) async -> Bool
    
    /// Plays audio feedback with specified volume
    /// - Parameter volume: Audio volume (0.0 to 1.0)
    /// - Returns: True if audio feedback was played successfully
    func playAudioFeedback(volume: Float) async -> Bool
}