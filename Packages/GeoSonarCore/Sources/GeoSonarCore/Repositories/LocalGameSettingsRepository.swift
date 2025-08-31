import Foundation

/// Local implementation of GameSettingsRepository using UserDefaults
public final class LocalGameSettingsRepository: GameSettingsRepository, @unchecked Sendable {
    
    private let userDefaults: UserDefaults
    
    // UserDefaults keys
    private enum Keys {
        static let audioEnabled = "gameSettings.audioEnabled"
        static let hapticsEnabled = "gameSettings.hapticsEnabled"
        static let audioVolume = "gameSettings.audioVolume"
    }
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    public func loadSettings() async -> GameSettings {
        // Check if values exist in UserDefaults, otherwise use defaults
        let audioEnabled: Bool
        if userDefaults.object(forKey: Keys.audioEnabled) != nil {
            audioEnabled = userDefaults.bool(forKey: Keys.audioEnabled)
        } else {
            audioEnabled = GameSettings.default.audioEnabled
        }
        
        let hapticsEnabled: Bool
        if userDefaults.object(forKey: Keys.hapticsEnabled) != nil {
            hapticsEnabled = userDefaults.bool(forKey: Keys.hapticsEnabled)
        } else {
            hapticsEnabled = GameSettings.default.hapticsEnabled
        }
        
        let audioVolume: Float
        if userDefaults.object(forKey: Keys.audioVolume) != nil {
            audioVolume = userDefaults.float(forKey: Keys.audioVolume)
        } else {
            audioVolume = GameSettings.default.audioVolume
        }
        
        return GameSettings(
            audioEnabled: audioEnabled,
            hapticsEnabled: hapticsEnabled,
            audioVolume: clampVolume(audioVolume)
        )
    }
    
    public func saveSettings(_ settings: GameSettings) async {
        userDefaults.set(settings.audioEnabled, forKey: Keys.audioEnabled)
        userDefaults.set(settings.hapticsEnabled, forKey: Keys.hapticsEnabled)
        userDefaults.set(clampVolume(settings.audioVolume), forKey: Keys.audioVolume)
    }
    
    public func updateAudioVolume(_ volume: Float) async {
        let clampedVolume = clampVolume(volume)
        userDefaults.set(clampedVolume, forKey: Keys.audioVolume)
    }
    
    public func updateAudioEnabled(_ enabled: Bool) async {
        userDefaults.set(enabled, forKey: Keys.audioEnabled)
    }
    
    public func updateHapticsEnabled(_ enabled: Bool) async {
        userDefaults.set(enabled, forKey: Keys.hapticsEnabled)
    }
    
    // MARK: - Private Helpers
    
    /// Clamp volume to valid range (0.0 to 1.0)
    private func clampVolume(_ volume: Float) -> Float {
        return max(0.0, min(1.0, volume))
    }
}