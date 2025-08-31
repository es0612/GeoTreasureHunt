import Testing
import Foundation
@testable import GeoSonarCore

@Suite("GameSettingsRepository Tests")
struct GameSettingsRepositoryTests {
    
    @Test("デフォルト設定の読み込み")
    func testLoadDefaultSettings() async throws {
        // Arrange
        let testDefaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let repository = LocalGameSettingsRepository(userDefaults: testDefaults)
        
        // Act
        let settings = await repository.loadSettings()
        
        // Assert
        #expect(settings.audioEnabled == true)
        #expect(settings.hapticsEnabled == true)
        #expect(settings.audioVolume == 0.8)
    }
    
    @Test("設定の保存と読み込み")
    func testSaveAndLoadSettings() async throws {
        // Arrange
        let testDefaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let repository = LocalGameSettingsRepository(userDefaults: testDefaults)
        let customSettings = GameSettings(
            audioEnabled: false,
            hapticsEnabled: true,
            audioVolume: 0.5
        )
        
        // Act
        await repository.saveSettings(customSettings)
        let loadedSettings = await repository.loadSettings()
        
        // Assert
        #expect(loadedSettings.audioEnabled == false)
        #expect(loadedSettings.hapticsEnabled == true)
        #expect(loadedSettings.audioVolume == 0.5)
    }
    
    @Test("音量設定の更新")
    func testUpdateAudioVolume() async throws {
        // Arrange
        let testDefaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let repository = LocalGameSettingsRepository(userDefaults: testDefaults)
        let initialSettings = GameSettings.default
        await repository.saveSettings(initialSettings)
        
        // Act
        await repository.updateAudioVolume(0.3)
        let updatedSettings = await repository.loadSettings()
        
        // Assert
        #expect(updatedSettings.audioVolume == 0.3)
        #expect(updatedSettings.audioEnabled == initialSettings.audioEnabled)
        #expect(updatedSettings.hapticsEnabled == initialSettings.hapticsEnabled)
    }
    
    @Test("オーディオ有効/無効の切り替え")
    func testToggleAudioEnabled() async throws {
        // Arrange
        let testDefaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let repository = LocalGameSettingsRepository(userDefaults: testDefaults)
        let initialSettings = GameSettings(audioEnabled: true, hapticsEnabled: true, audioVolume: 0.8)
        await repository.saveSettings(initialSettings)
        
        // Act
        await repository.updateAudioEnabled(false)
        let updatedSettings = await repository.loadSettings()
        
        // Assert
        #expect(updatedSettings.audioEnabled == false)
        #expect(updatedSettings.hapticsEnabled == initialSettings.hapticsEnabled)
        #expect(updatedSettings.audioVolume == initialSettings.audioVolume)
    }
    
    @Test("ハプティック有効/無効の切り替え")
    func testToggleHapticsEnabled() async throws {
        // Arrange
        let testDefaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let repository = LocalGameSettingsRepository(userDefaults: testDefaults)
        let initialSettings = GameSettings(audioEnabled: true, hapticsEnabled: true, audioVolume: 0.8)
        await repository.saveSettings(initialSettings)
        
        // Act
        await repository.updateHapticsEnabled(false)
        let updatedSettings = await repository.loadSettings()
        
        // Assert
        #expect(updatedSettings.hapticsEnabled == false)
        #expect(updatedSettings.audioEnabled == initialSettings.audioEnabled)
        #expect(updatedSettings.audioVolume == initialSettings.audioVolume)
    }
    
    @Test("設定の即座反映")
    func testImmediateSettingsReflection() async throws {
        // Arrange
        let testDefaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let repository = LocalGameSettingsRepository(userDefaults: testDefaults)
        
        // Act & Assert - 複数の設定変更を連続で行う
        await repository.updateAudioVolume(0.2)
        let settings1 = await repository.loadSettings()
        #expect(settings1.audioVolume == 0.2)
        
        await repository.updateAudioEnabled(false)
        let settings2 = await repository.loadSettings()
        #expect(settings2.audioEnabled == false)
        #expect(settings2.audioVolume == 0.2) // 前の設定が保持されている
        
        await repository.updateHapticsEnabled(false)
        let settings3 = await repository.loadSettings()
        #expect(settings3.hapticsEnabled == false)
        #expect(settings3.audioEnabled == false)
        #expect(settings3.audioVolume == 0.2)
    }
    
    @Test("無効な音量値の処理")
    func testInvalidVolumeHandling() async throws {
        // Arrange
        let testDefaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let repository = LocalGameSettingsRepository(userDefaults: testDefaults)
        
        // Act & Assert - 範囲外の値をテスト
        await repository.updateAudioVolume(-0.5) // 負の値
        let settings1 = await repository.loadSettings()
        #expect(settings1.audioVolume == 0.0) // 0.0にクランプされる
        
        await repository.updateAudioVolume(1.5) // 1.0を超える値
        let settings2 = await repository.loadSettings()
        #expect(settings2.audioVolume == 1.0) // 1.0にクランプされる
    }
}