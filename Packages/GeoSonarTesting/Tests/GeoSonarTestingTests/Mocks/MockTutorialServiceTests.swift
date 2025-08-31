import Testing
import Foundation
@testable import GeoSonarTesting
@testable import GeoSonarCore

@Suite("MockTutorialService Tests")
struct MockTutorialServiceTests {
    
    @Test("初期状態の設定")
    func testInitialState() async throws {
        // Arrange
        let mock = MockTutorialService(
            isFirstLaunch: false,
            isTutorialCompleted: true,
            currentTutorialStep: .sonarExplanation,
            isHelpAccessEnabled: false
        )
        
        // Act & Assert
        #expect(await mock.isFirstLaunch() == false)
        #expect(await mock.isTutorialCompleted() == true)
        #expect(await mock.getCurrentTutorialStep() == .sonarExplanation)
        #expect(await mock.isHelpAccessEnabled() == false)
    }
    
    @Test("初回起動状態の管理")
    func testFirstLaunchStateManagement() async throws {
        // Arrange
        let mock = MockTutorialService()
        
        // Act & Assert - 初期状態
        #expect(await mock.isFirstLaunch() == true)
        #expect(mock.isFirstLaunchCallCount == 1)
        
        // Act - 初回起動完了をマーク
        await mock.markFirstLaunchCompleted()
        
        // Assert
        #expect(await mock.isFirstLaunch() == false)
        #expect(mock.markFirstLaunchCompletedCallCount == 1)
    }
    
    @Test("チュートリアル完了状態の管理")
    func testTutorialCompletionStateManagement() async throws {
        // Arrange
        let mock = MockTutorialService()
        
        // Act & Assert - 初期状態
        #expect(await mock.isTutorialCompleted() == false)
        #expect(mock.isTutorialCompletedCallCount == 1)
        
        // Act - チュートリアル完了をマーク
        await mock.markTutorialCompleted()
        
        // Assert
        #expect(await mock.isTutorialCompleted() == true)
        #expect(await mock.getCurrentTutorialStep() == .completed)
        #expect(mock.markTutorialCompletedCallCount == 1)
    }
    
    @Test("チュートリアルステップの管理")
    func testTutorialStepManagement() async throws {
        // Arrange
        let mock = MockTutorialService()
        
        // Act & Assert - 初期状態
        #expect(await mock.getCurrentTutorialStep() == .welcome)
        #expect(mock.getCurrentTutorialStepCallCount == 1)
        
        // Act - ステップを変更
        await mock.setCurrentTutorialStep(.dowsingExplanation)
        
        // Assert
        #expect(await mock.getCurrentTutorialStep() == .dowsingExplanation)
        #expect(mock.setCurrentTutorialStepCallCount == 1)
    }
    
    @Test("次のステップへの進行")
    func testAdvanceToNextStep() async throws {
        // Arrange
        let mock = MockTutorialService(currentTutorialStep: .welcome)
        
        // Act
        await mock.advanceToNextStep()
        
        // Assert
        #expect(await mock.getCurrentTutorialStep() == .dowsingExplanation)
        #expect(mock.advanceToNextStepCallCount == 1)
    }
    
    @Test("チュートリアルスキップ機能")
    func testSkipTutorial() async throws {
        // Arrange
        let mock = MockTutorialService()
        
        // Act
        await mock.skipTutorial()
        
        // Assert
        #expect(await mock.isTutorialCompleted() == true)
        #expect(await mock.getCurrentTutorialStep() == .completed)
        #expect(mock.skipTutorialCallCount == 1)
    }
    
    @Test("チュートリアルリセット機能")
    func testResetTutorial() async throws {
        // Arrange
        let mock = MockTutorialService(
            isFirstLaunch: false,
            isTutorialCompleted: true,
            currentTutorialStep: .completed
        )
        
        // Act
        await mock.resetTutorial()
        
        // Assert
        #expect(await mock.isTutorialCompleted() == false)
        #expect(await mock.getCurrentTutorialStep() == .welcome)
        #expect(mock.resetTutorialCallCount == 1)
    }
    
    @Test("ヘルプアクセス設定の管理")
    func testHelpAccessSettings() async throws {
        // Arrange
        let mock = MockTutorialService()
        
        // Act & Assert - 初期状態
        #expect(await mock.isHelpAccessEnabled() == true)
        #expect(mock.isHelpAccessEnabledCallCount == 1)
        
        // Act - ヘルプアクセスを無効にする
        await mock.setHelpAccessEnabled(false)
        
        // Assert
        #expect(await mock.isHelpAccessEnabled() == false)
        #expect(mock.setHelpAccessEnabledCallCount == 1)
    }
    
    @Test("チュートリアル表示判定")
    func testShouldShowTutorial() async throws {
        // Arrange
        let mock = MockTutorialService()
        
        // Act & Assert - 初回起動時
        #expect(await mock.shouldShowTutorial() == true)
        #expect(mock.shouldShowTutorialCallCount == 1)
        
        // Act - チュートリアル完了
        await mock.markTutorialCompleted()
        await mock.markFirstLaunchCompleted()
        
        // Assert - 完了後は表示しない
        #expect(await mock.shouldShowTutorial() == false)
    }
    
    @Test("チュートリアル進行状況の計算")
    func testGetTutorialProgress() async throws {
        // Arrange
        let mock = MockTutorialService()
        
        // Act & Assert - 各ステップでの進行状況
        await mock.setCurrentTutorialStep(.welcome)
        #expect(await mock.getTutorialProgress() == 0.0)
        
        await mock.setCurrentTutorialStep(.dowsingExplanation)
        #expect(await mock.getTutorialProgress() == 0.25)
        
        await mock.setCurrentTutorialStep(.sonarExplanation)
        #expect(await mock.getTutorialProgress() == 0.5)
        
        await mock.setCurrentTutorialStep(.practiceMode)
        #expect(await mock.getTutorialProgress() == 0.75)
        
        await mock.setCurrentTutorialStep(.completed)
        #expect(await mock.getTutorialProgress() == 1.0)
        
        #expect(mock.getTutorialProgressCallCount == 5)
    }
    
    @Test("呼び出し回数のリセット")
    func testResetCallCounts() async throws {
        // Arrange
        let mock = MockTutorialService()
        
        // Act - いくつかのメソッドを呼び出し
        await mock.isFirstLaunch()
        await mock.isTutorialCompleted()
        await mock.getCurrentTutorialStep()
        
        // Assert - 呼び出し回数が記録されている
        #expect(mock.isFirstLaunchCallCount == 1)
        #expect(mock.isTutorialCompletedCallCount == 1)
        #expect(mock.getCurrentTutorialStepCallCount == 1)
        
        // Act - リセット
        mock.resetCallCounts()
        
        // Assert - 呼び出し回数がリセットされている
        #expect(mock.isFirstLaunchCallCount == 0)
        #expect(mock.isTutorialCompletedCallCount == 0)
        #expect(mock.getCurrentTutorialStepCallCount == 0)
    }
    
    @Test("状態の直接設定")
    func testSetStateDirectly() async throws {
        // Arrange
        let mock = MockTutorialService()
        
        // Act
        mock.setState(
            isFirstLaunch: false,
            isTutorialCompleted: true,
            currentTutorialStep: .practiceMode,
            isHelpAccessEnabled: false
        )
        
        // Assert
        #expect(await mock.isFirstLaunch() == false)
        #expect(await mock.isTutorialCompleted() == true)
        #expect(await mock.getCurrentTutorialStep() == .practiceMode)
        #expect(await mock.isHelpAccessEnabled() == false)
    }
}