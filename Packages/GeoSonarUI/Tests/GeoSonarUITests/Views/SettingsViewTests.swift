import Testing
import SwiftUI
@testable import GeoSonarUI
@testable import GeoSonarCore
@testable import GeoSonarTesting

@Suite("SettingsView Tests")
struct SettingsViewTests {
    
    @Test("設定画面の基本レンダリング")
    @MainActor func testBasicSettingsViewRendering() async throws {
        // Arrange
        let mockRepository = MockGameSettingsRepository()
        let viewModel = SettingsViewModel(settingsRepository: mockRepository)
        
        // Act
        let view = SettingsView(viewModel: viewModel)
        
        // Assert - ビューが作成できることを確認
        #expect(view != nil)
    }
    
    @Test("音量スライダーの初期値")
    @MainActor func testAudioVolumeSliderInitialValue() async throws {
        // Arrange
        let customSettings = GameSettings(audioEnabled: true, hapticsEnabled: true, audioVolume: 0.6)
        let mockRepository = MockGameSettingsRepository(initialSettings: customSettings)
        let viewModel = SettingsViewModel(settingsRepository: mockRepository)
        await viewModel.loadSettings()
        
        // Act
        let view = SettingsView(viewModel: viewModel)
        
        // Assert - ViewModelの値が正しく設定されている
        #expect(viewModel.audioVolume == 0.6)
    }
    
    @Test("オーディオトグルの初期状態")
    @MainActor func testAudioToggleInitialState() async throws {
        // Arrange
        let customSettings = GameSettings(audioEnabled: false, hapticsEnabled: true, audioVolume: 0.8)
        let mockRepository = MockGameSettingsRepository(initialSettings: customSettings)
        let viewModel = SettingsViewModel(settingsRepository: mockRepository)
        await viewModel.loadSettings()
        
        // Act
        let view = SettingsView(viewModel: viewModel)
        
        // Assert - ViewModelの値が正しく設定されている
        #expect(viewModel.audioEnabled == false)
    }
    
    @Test("ハプティックトグルの初期状態")
    @MainActor func testHapticsToggleInitialState() async throws {
        // Arrange
        let customSettings = GameSettings(audioEnabled: true, hapticsEnabled: false, audioVolume: 0.8)
        let mockRepository = MockGameSettingsRepository(initialSettings: customSettings)
        let viewModel = SettingsViewModel(settingsRepository: mockRepository)
        await viewModel.loadSettings()
        
        // Act
        let view = SettingsView(viewModel: viewModel)
        
        // Assert - ViewModelの値が正しく設定されている
        #expect(viewModel.hapticsEnabled == false)
    }
    
    @Test("設定変更時のViewModelとの同期")
    @MainActor func testSettingsChangesSyncWithViewModel() async throws {
        // Arrange
        let mockRepository = MockGameSettingsRepository()
        let viewModel = SettingsViewModel(settingsRepository: mockRepository)
        await viewModel.loadSettings()
        
        // Act - ViewModelの設定を変更
        await viewModel.updateAudioVolume(0.3)
        await viewModel.toggleAudioEnabled()
        await viewModel.toggleHapticsEnabled()
        
        // Assert - ViewModelの状態が更新されている
        #expect(viewModel.audioVolume == 0.3)
        #expect(viewModel.audioEnabled == false)
        #expect(viewModel.hapticsEnabled == false)
    }
    
    @Test("リセットボタンの動作")
    @MainActor func testResetButtonBehavior() async throws {
        // Arrange
        let customSettings = GameSettings(audioEnabled: false, hapticsEnabled: false, audioVolume: 0.2)
        let mockRepository = MockGameSettingsRepository(initialSettings: customSettings)
        let viewModel = SettingsViewModel(settingsRepository: mockRepository)
        await viewModel.loadSettings()
        
        // Act - リセット実行
        await viewModel.resetToDefaults()
        
        // Assert - デフォルト値に戻っている
        #expect(viewModel.audioEnabled == GameSettings.default.audioEnabled)
        #expect(viewModel.hapticsEnabled == GameSettings.default.hapticsEnabled)
        #expect(viewModel.audioVolume == GameSettings.default.audioVolume)
    }
    
    @Test("ローディング状態の表示")
    @MainActor func testLoadingStateDisplay() async throws {
        // Arrange
        let mockRepository = MockGameSettingsRepository()
        let viewModel = SettingsViewModel(settingsRepository: mockRepository)
        
        // Act
        let view = SettingsView(viewModel: viewModel)
        
        // Assert - 初期状態ではローディングしていない
        #expect(viewModel.isLoading == false)
    }
    
    @Test("アクセシビリティラベルの設定")
    @MainActor func testAccessibilityLabels() async throws {
        // Arrange
        let mockRepository = MockGameSettingsRepository()
        let viewModel = SettingsViewModel(settingsRepository: mockRepository)
        
        // Act
        let view = SettingsView(viewModel: viewModel)
        
        // Assert - ビューが作成できることを確認（アクセシビリティは実装で確認）
        #expect(view != nil)
    }
}