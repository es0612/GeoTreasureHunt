import Testing
import Foundation
@testable import GeoSonarUI
@testable import GeoSonarCore
@testable import GeoSonarTesting

@Suite("SettingsViewModel Tests")
struct SettingsViewModelTests {
    
    @Test("初期設定の読み込み")
    @MainActor func testInitialSettingsLoad() async throws {
        // Arrange
        let mockRepository = MockGameSettingsRepository(
            initialSettings: GameSettings(audioEnabled: false, hapticsEnabled: true, audioVolume: 0.6)
        )
        let viewModel = SettingsViewModel(settingsRepository: mockRepository)
        
        // Act
        await viewModel.loadSettings()
        
        // Assert
        #expect(viewModel.audioEnabled == false)
        #expect(viewModel.hapticsEnabled == true)
        #expect(viewModel.audioVolume == 0.6)
        #expect(mockRepository.loadSettingsCallCount == 1)
    }
    
    @Test("音量変更の即座反映")
    @MainActor func testAudioVolumeChangeImmediateReflection() async throws {
        // Arrange
        let mockRepository = MockGameSettingsRepository()
        let viewModel = SettingsViewModel(settingsRepository: mockRepository)
        await viewModel.loadSettings()
        
        // Act
        await viewModel.updateAudioVolume(0.3)
        
        // Assert
        #expect(viewModel.audioVolume == 0.3)
        #expect(mockRepository.updateAudioVolumeCallCount == 1)
    }
    
    @Test("オーディオ有効/無効切り替えの即座反映")
    @MainActor func testAudioEnabledToggleImmediateReflection() async throws {
        // Arrange
        let mockRepository = MockGameSettingsRepository()
        let viewModel = SettingsViewModel(settingsRepository: mockRepository)
        await viewModel.loadSettings()
        
        // Act
        await viewModel.toggleAudioEnabled()
        
        // Assert
        #expect(viewModel.audioEnabled == false) // デフォルトはtrueなのでfalseになる
        #expect(mockRepository.updateAudioEnabledCallCount == 1)
    }
    
    @Test("ハプティック有効/無効切り替えの即座反映")
    @MainActor func testHapticsEnabledToggleImmediateReflection() async throws {
        // Arrange
        let mockRepository = MockGameSettingsRepository()
        let viewModel = SettingsViewModel(settingsRepository: mockRepository)
        await viewModel.loadSettings()
        
        // Act
        await viewModel.toggleHapticsEnabled()
        
        // Assert
        #expect(viewModel.hapticsEnabled == false) // デフォルトはtrueなのでfalseになる
        #expect(mockRepository.updateHapticsEnabledCallCount == 1)
    }
    
    @Test("複数設定変更の連続処理")
    @MainActor func testMultipleSettingsChanges() async throws {
        // Arrange
        let mockRepository = MockGameSettingsRepository()
        let viewModel = SettingsViewModel(settingsRepository: mockRepository)
        await viewModel.loadSettings()
        
        // Act - 複数の設定を連続で変更
        await viewModel.updateAudioVolume(0.2)
        await viewModel.toggleAudioEnabled()
        await viewModel.toggleHapticsEnabled()
        
        // Assert
        #expect(viewModel.audioVolume == 0.2)
        #expect(viewModel.audioEnabled == false)
        #expect(viewModel.hapticsEnabled == false)
        #expect(mockRepository.updateAudioVolumeCallCount == 1)
        #expect(mockRepository.updateAudioEnabledCallCount == 1)
        #expect(mockRepository.updateHapticsEnabledCallCount == 1)
    }
    
    @Test("設定リセット機能")
    @MainActor func testResetToDefaults() async throws {
        // Arrange
        let mockRepository = MockGameSettingsRepository(
            initialSettings: GameSettings(audioEnabled: false, hapticsEnabled: false, audioVolume: 0.1)
        )
        let viewModel = SettingsViewModel(settingsRepository: mockRepository)
        await viewModel.loadSettings()
        
        // Act
        await viewModel.resetToDefaults()
        
        // Assert
        #expect(viewModel.audioEnabled == GameSettings.default.audioEnabled)
        #expect(viewModel.hapticsEnabled == GameSettings.default.hapticsEnabled)
        #expect(viewModel.audioVolume == GameSettings.default.audioVolume)
        #expect(mockRepository.saveSettingsCallCount == 1)
    }
    
    @Test("ローディング状態の管理")
    @MainActor func testLoadingStateManagement() async throws {
        // Arrange
        let mockRepository = MockGameSettingsRepository()
        let viewModel = SettingsViewModel(settingsRepository: mockRepository)
        
        // Assert - 初期状態
        #expect(viewModel.isLoading == false)
        
        // Act & Assert - ローディング中
        let loadTask = Task {
            await viewModel.loadSettings()
        }
        
        // ローディング完了を待つ
        await loadTask.value
        
        // Assert - ローディング完了
        #expect(viewModel.isLoading == false)
    }
    
    @Test("無効な音量値の処理")
    @MainActor func testInvalidVolumeHandling() async throws {
        // Arrange
        let mockRepository = MockGameSettingsRepository()
        let viewModel = SettingsViewModel(settingsRepository: mockRepository)
        await viewModel.loadSettings()
        
        // Act & Assert - 負の値
        await viewModel.updateAudioVolume(-0.5)
        #expect(viewModel.audioVolume == 0.0)
        
        // Act & Assert - 1.0を超える値
        await viewModel.updateAudioVolume(1.5)
        #expect(viewModel.audioVolume == 1.0)
    }
}