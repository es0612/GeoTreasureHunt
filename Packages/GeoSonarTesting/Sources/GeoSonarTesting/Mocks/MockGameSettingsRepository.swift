import Foundation
import GeoSonarCore

/// Mock implementation of GameSettingsRepository for testing
public final class MockGameSettingsRepository: GameSettingsRepository, @unchecked Sendable {
    
    private var settings: GameSettings = .default
    
    // Test tracking properties
    public private(set) var loadSettingsCallCount = 0
    public private(set) var saveSettingsCallCount = 0
    public private(set) var updateAudioVolumeCallCount = 0
    public private(set) var updateAudioEnabledCallCount = 0
    public private(set) var updateHapticsEnabledCallCount = 0
    
    public init(initialSettings: GameSettings = .default) {
        self.settings = initialSettings
    }
    
    public func loadSettings() async -> GameSettings {
        loadSettingsCallCount += 1
        return settings
    }
    
    public func saveSettings(_ settings: GameSettings) async {
        saveSettingsCallCount += 1
        self.settings = settings
    }
    
    public func updateAudioVolume(_ volume: Float) async {
        updateAudioVolumeCallCount += 1
        settings = GameSettings(
            audioEnabled: settings.audioEnabled,
            hapticsEnabled: settings.hapticsEnabled,
            audioVolume: volume
        )
    }
    
    public func updateAudioEnabled(_ enabled: Bool) async {
        updateAudioEnabledCallCount += 1
        settings = GameSettings(
            audioEnabled: enabled,
            hapticsEnabled: settings.hapticsEnabled,
            audioVolume: settings.audioVolume
        )
    }
    
    public func updateHapticsEnabled(_ enabled: Bool) async {
        updateHapticsEnabledCallCount += 1
        settings = GameSettings(
            audioEnabled: settings.audioEnabled,
            hapticsEnabled: enabled,
            audioVolume: settings.audioVolume
        )
    }
    
    // MARK: - Test Helpers
    
    /// Reset all call counts for testing
    public func resetCallCounts() {
        loadSettingsCallCount = 0
        saveSettingsCallCount = 0
        updateAudioVolumeCallCount = 0
        updateAudioEnabledCallCount = 0
        updateHapticsEnabledCallCount = 0
    }
    
    /// Set settings directly for testing
    public func setSettings(_ settings: GameSettings) {
        self.settings = settings
    }
}