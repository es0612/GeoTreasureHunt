import Testing
import Foundation
@testable import GeoSonarUI
@testable import GeoSonarCore
@testable import GeoSonarTesting

@Suite("TutorialViewModel Tests")
struct TutorialViewModelTests {
    
    @Test("初期状態の読み込み")
    @MainActor func testInitialStateLoad() async throws {
        // Arrange
        let mockTutorialService = MockTutorialService(
            isFirstLaunch: true,
            isTutorialCompleted: false,
            currentTutorialStep: .welcome
        )
        let viewModel = TutorialViewModel(tutorialService: mockTutorialService)
        
        // Act
        await viewModel.loadTutorialState()
        
        // Assert
        #expect(viewModel.isFirstLaunch == true)
        #expect(viewModel.isTutorialCompleted == false)
        #expect(viewModel.currentStep == .welcome)
        #expect(viewModel.shouldShowTutorial == true)
        #expect(mockTutorialService.isFirstLaunchCallCount == 1)
        #expect(mockTutorialService.isTutorialCompletedCallCount == 1)
        #expect(mockTutorialService.getCurrentTutorialStepCallCount == 1)
        #expect(mockTutorialService.shouldShowTutorialCallCount == 1)
    }
    
    @Test("次のステップへの進行")
    @MainActor func testAdvanceToNextStep() async throws {
        // Arrange
        let mockTutorialService = MockTutorialService(currentTutorialStep: .welcome)
        let viewModel = TutorialViewModel(tutorialService: mockTutorialService)
        await viewModel.loadTutorialState()
        
        // Act
        await viewModel.advanceToNextStep()
        
        // Assert
        #expect(viewModel.currentStep == .dowsingExplanation)
        #expect(mockTutorialService.advanceToNextStepCallCount == 1)
    }
    
    @Test("特定のステップへの移動")
    @MainActor func testGoToStep() async throws {
        // Arrange
        let mockTutorialService = MockTutorialService()
        let viewModel = TutorialViewModel(tutorialService: mockTutorialService)
        await viewModel.loadTutorialState()
        
        // Act
        await viewModel.goToStep(.sonarExplanation)
        
        // Assert
        #expect(viewModel.currentStep == .sonarExplanation)
        #expect(mockTutorialService.setCurrentTutorialStepCallCount == 1)
    }
    
    @Test("チュートリアルスキップ機能")
    @MainActor func testSkipTutorial() async throws {
        // Arrange
        let mockTutorialService = MockTutorialService()
        let viewModel = TutorialViewModel(tutorialService: mockTutorialService)
        await viewModel.loadTutorialState()
        
        // Act
        await viewModel.skipTutorial()
        
        // Assert
        #expect(viewModel.isTutorialCompleted == true)
        #expect(viewModel.currentStep == .completed)
        #expect(viewModel.shouldShowTutorial == false)
        #expect(mockTutorialService.skipTutorialCallCount == 1)
    }
    
    @Test("チュートリアル完了処理")
    @MainActor func testCompleteTutorial() async throws {
        // Arrange
        let mockTutorialService = MockTutorialService()
        let viewModel = TutorialViewModel(tutorialService: mockTutorialService)
        await viewModel.loadTutorialState()
        
        // Act
        await viewModel.completeTutorial()
        
        // Assert
        #expect(viewModel.isTutorialCompleted == true)
        #expect(viewModel.currentStep == .completed)
        #expect(mockTutorialService.markTutorialCompletedCallCount == 1)
    }
    
    @Test("チュートリアルリセット機能")
    @MainActor func testResetTutorial() async throws {
        // Arrange
        let mockTutorialService = MockTutorialService(
            isTutorialCompleted: true,
            currentTutorialStep: .completed
        )
        let viewModel = TutorialViewModel(tutorialService: mockTutorialService)
        await viewModel.loadTutorialState()
        
        // Act
        await viewModel.resetTutorial()
        
        // Assert
        #expect(viewModel.isTutorialCompleted == false)
        #expect(viewModel.currentStep == .welcome)
        #expect(viewModel.shouldShowTutorial == true)
        #expect(mockTutorialService.resetTutorialCallCount == 1)
    }
    
    @Test("進行状況の計算")
    @MainActor func testProgressCalculation() async throws {
        // Arrange
        let mockTutorialService = MockTutorialService()
        let viewModel = TutorialViewModel(tutorialService: mockTutorialService)
        
        // Act & Assert - 各ステップでの進行状況
        await viewModel.goToStep(.welcome)
        #expect(viewModel.progress == 0.0)
        
        await viewModel.goToStep(.dowsingExplanation)
        #expect(viewModel.progress == 0.25)
        
        await viewModel.goToStep(.sonarExplanation)
        #expect(viewModel.progress == 0.5)
        
        await viewModel.goToStep(.practiceMode)
        #expect(viewModel.progress == 0.75)
        
        await viewModel.goToStep(.completed)
        #expect(viewModel.progress == 1.0)
    }
    
    @Test("ローディング状態の管理")
    @MainActor func testLoadingStateManagement() async throws {
        // Arrange
        let mockTutorialService = MockTutorialService()
        let viewModel = TutorialViewModel(tutorialService: mockTutorialService)
        
        // Assert - 初期状態
        #expect(viewModel.isLoading == false)
        
        // Act & Assert - ローディング中
        let loadTask = Task {
            await viewModel.loadTutorialState()
        }
        
        // ローディング完了を待つ
        await loadTask.value
        
        // Assert - ローディング完了
        #expect(viewModel.isLoading == false)
    }
    
    @Test("ヘルプアクセス設定の管理")
    @MainActor func testHelpAccessSettings() async throws {
        // Arrange
        let mockTutorialService = MockTutorialService()
        let viewModel = TutorialViewModel(tutorialService: mockTutorialService)
        await viewModel.loadTutorialState()
        
        // Act & Assert - 初期状態
        #expect(viewModel.isHelpAccessEnabled == true)
        
        // Act - ヘルプアクセスを無効にする
        await viewModel.setHelpAccessEnabled(false)
        
        // Assert
        #expect(viewModel.isHelpAccessEnabled == false)
        #expect(mockTutorialService.setHelpAccessEnabledCallCount == 1)
    }
    
    @Test("ステップ検証機能")
    @MainActor func testStepValidation() async throws {
        // Arrange
        let mockTutorialService = MockTutorialService()
        let viewModel = TutorialViewModel(tutorialService: mockTutorialService)
        await viewModel.loadTutorialState()
        
        // Act & Assert - 各ステップの検証
        await viewModel.goToStep(.welcome)
        #expect(viewModel.isWelcomeStep == true)
        #expect(viewModel.isDowsingStep == false)
        #expect(viewModel.isSonarStep == false)
        #expect(viewModel.isPracticeStep == false)
        #expect(viewModel.isCompletedStep == false)
        
        await viewModel.goToStep(.dowsingExplanation)
        #expect(viewModel.isWelcomeStep == false)
        #expect(viewModel.isDowsingStep == true)
        
        await viewModel.goToStep(.sonarExplanation)
        #expect(viewModel.isSonarStep == true)
        
        await viewModel.goToStep(.practiceMode)
        #expect(viewModel.isPracticeStep == true)
        
        await viewModel.goToStep(.completed)
        #expect(viewModel.isCompletedStep == true)
    }
    
    @Test("次のステップ存在確認")
    @MainActor func testHasNextStep() async throws {
        // Arrange
        let mockTutorialService = MockTutorialService()
        let viewModel = TutorialViewModel(tutorialService: mockTutorialService)
        
        // Act & Assert - 各ステップでの次のステップ存在確認
        await viewModel.goToStep(.welcome)
        #expect(viewModel.hasNextStep == true)
        
        await viewModel.goToStep(.dowsingExplanation)
        #expect(viewModel.hasNextStep == true)
        
        await viewModel.goToStep(.sonarExplanation)
        #expect(viewModel.hasNextStep == true)
        
        await viewModel.goToStep(.practiceMode)
        #expect(viewModel.hasNextStep == true)
        
        await viewModel.goToStep(.completed)
        #expect(viewModel.hasNextStep == false)
    }
}