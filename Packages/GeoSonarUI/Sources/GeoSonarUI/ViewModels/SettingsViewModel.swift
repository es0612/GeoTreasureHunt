import Foundation
import GeoSonarCore

/// ViewModel for managing game settings
@available(iOS 15.0, macOS 14.0, *)
@Observable
@MainActor
public final class SettingsViewModel {
    
    // MARK: - Published Properties
    
    public private(set) var audioEnabled: Bool = GameSettings.default.audioEnabled
    public private(set) var hapticsEnabled: Bool = GameSettings.default.hapticsEnabled
    public private(set) var audioVolume: Float = GameSettings.default.audioVolume
    public private(set) var isLoading: Bool = false
    
    // MARK: - Dependencies
    
    private let settingsRepository: GameSettingsRepository
    
    // MARK: - Initialization
    
    public init(settingsRepository: GameSettingsRepository) {
        self.settingsRepository = settingsRepository
    }
    
    // MARK: - Public Methods
    
    /// Load current settings from repository
    public func loadSettings() async {
        isLoading = true
        defer { isLoading = false }
        
        let settings = await settingsRepository.loadSettings()
        audioEnabled = settings.audioEnabled
        hapticsEnabled = settings.hapticsEnabled
        audioVolume = settings.audioVolume
    }
    
    /// Update audio volume setting
    public func updateAudioVolume(_ volume: Float) async {
        let clampedVolume = clampVolume(volume)
        audioVolume = clampedVolume
        await settingsRepository.updateAudioVolume(clampedVolume)
    }
    
    /// Toggle audio enabled setting
    public func toggleAudioEnabled() async {
        audioEnabled.toggle()
        await settingsRepository.updateAudioEnabled(audioEnabled)
    }
    
    /// Toggle haptics enabled setting
    public func toggleHapticsEnabled() async {
        hapticsEnabled.toggle()
        await settingsRepository.updateHapticsEnabled(hapticsEnabled)
    }
    
    /// Reset all settings to defaults
    public func resetToDefaults() async {
        let defaultSettings = GameSettings.default
        audioEnabled = defaultSettings.audioEnabled
        hapticsEnabled = defaultSettings.hapticsEnabled
        audioVolume = defaultSettings.audioVolume
        
        await settingsRepository.saveSettings(defaultSettings)
    }
    
    // MARK: - Private Helpers
    
    /// Clamp volume to valid range (0.0 to 1.0)
    private func clampVolume(_ volume: Float) -> Float {
        return max(0.0, min(1.0, volume))
    }
    
    /// Get current settings as GameSettings struct
    public var currentSettings: GameSettings {
        GameSettings(
            audioEnabled: audioEnabled,
            hapticsEnabled: hapticsEnabled,
            audioVolume: audioVolume
        )
    }
}