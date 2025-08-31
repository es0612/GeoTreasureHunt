import Testing
import Foundation
@testable import GeoSonarTesting
@testable import GeoSonarCore

@Suite("MockGameSettingsRepository Tests")
struct MockGameSettingsRepositoryTests {
    
    @Test("初期設定の読み込み")
    func testInitialSettingsLoad() async throws {
        // Arrange
        let customSettings = GameSettings(audioEnabled: false, hapticsEnabled: false, audioVolume: 0.3)
        let mock = MockGameSettingsRepository(initialSettings: customSettings)
        
        // Act
        let settings = await mock.loadSettings()
        
        // Assert
        #expect(settings.audioEnabled == false)
        #expect(settings.hapticsEnabled == false)
        #expect(settings.audioVolume == 0.3)
        #expect(mock.loadSettingsCallCount == 1)
    }
    
    @Test("設定の保存")
    func testSaveSettings() async throws {
        // Arrange
        let mock = MockGameSettingsRepository()
        let newSettings = GameSettings(audioEnabled: false, hapticsEnabled: true, audioVolume: 0.6)
        
        // Act
        await mock.saveSettings(newSettings)
        let loadedSettings = await mock.loadSettings()
        
        // Assert
        #expect(loadedSettings.audioEnabled == false)
        #expect(loadedSettings.hapticsEnabled == true)
        #expect(loadedSettings.audioVolume == 0.6)
        #expect(mock.saveSettingsCallCount == 1)
        #expect(mock.loadSettingsCallCount == 1)
    }
    
    @Test("音量更新の追跡")
    func testUpdateAudioVolumeTracking() async throws {
        // Arrange
        let mock = MockGameSettingsRepository()
        
        // Act
        await mock.updateAudioVolume(0.4)
        let settings = await mock.loadSettings()
        
        // Assert
        #expect(settings.audioVolume == 0.4)
        #expect(mock.updateAudioVolumeCallCount == 1)
    }
    
    @Test("オーディオ有効/無効更新の追跡")
    func testUpdateAudioEnabledTracking() async throws {
        // Arrange
        let mock = MockGameSettingsRepository()
        
        // Act
        await mock.updateAudioEnabled(false)
        let settings = await mock.loadSettings()
        
        // Assert
        #expect(settings.audioEnabled == false)
        #expect(mock.updateAudioEnabledCallCount == 1)
    }
    
    @Test("ハプティック有効/無効更新の追跡")
    func testUpdateHapticsEnabledTracking() async throws {
        // Arrange
        let mock = MockGameSettingsRepository()
        
        // Act
        await mock.updateHapticsEnabled(false)
        let settings = await mock.loadSettings()
        
        // Assert
        #expect(settings.hapticsEnabled == false)
        #expect(mock.updateHapticsEnabledCallCount == 1)
    }
    
    @Test("呼び出し回数のリセット")
    func testResetCallCounts() async throws {
        // Arrange
        let mock = MockGameSettingsRepository()
        
        // Act - いくつかのメソッドを呼び出し
        await mock.loadSettings()
        await mock.saveSettings(.default)
        await mock.updateAudioVolume(0.5)
        
        // Assert - 呼び出し回数が記録されている
        #expect(mock.loadSettingsCallCount == 1)
        #expect(mock.saveSettingsCallCount == 1)
        #expect(mock.updateAudioVolumeCallCount == 1)
        
        // Act - リセット
        mock.resetCallCounts()
        
        // Assert - 呼び出し回数がリセットされている
        #expect(mock.loadSettingsCallCount == 0)
        #expect(mock.saveSettingsCallCount == 0)
        #expect(mock.updateAudioVolumeCallCount == 0)
    }
    
    @Test("設定の直接設定")
    func testSetSettingsDirectly() async throws {
        // Arrange
        let mock = MockGameSettingsRepository()
        let testSettings = GameSettings(audioEnabled: false, hapticsEnabled: false, audioVolume: 0.2)
        
        // Act
        mock.setSettings(testSettings)
        let settings = await mock.loadSettings()
        
        // Assert
        #expect(settings.audioEnabled == false)
        #expect(settings.hapticsEnabled == false)
        #expect(settings.audioVolume == 0.2)
    }
}