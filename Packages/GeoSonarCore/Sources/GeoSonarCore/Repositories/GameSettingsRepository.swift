import Foundation

/// Protocol for managing game settings persistence
public protocol GameSettingsRepository: Sendable {
    /// Load current game settings
    func loadSettings() async -> GameSettings
    
    /// Save game settings
    func saveSettings(_ settings: GameSettings) async
    
    /// Update audio volume setting
    func updateAudioVolume(_ volume: Float) async
    
    /// Update audio enabled setting
    func updateAudioEnabled(_ enabled: Bool) async
    
    /// Update haptics enabled setting
    func updateHapticsEnabled(_ enabled: Bool) async
}