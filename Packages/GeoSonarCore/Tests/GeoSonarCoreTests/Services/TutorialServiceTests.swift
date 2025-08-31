import Testing
import Foundation
@testable import GeoSonarCore

@Suite("TutorialService Tests")
struct TutorialServiceTests {
    
    @Test("初回起動検出 - 初回起動時")
    func testFirstLaunchDetection() async throws {
        // Arrange
        let testDefaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let service = TutorialService(userDefaults: testDefaults)
        
        // Act
        let isFirstLaunch = await service.isFirstLaunch()
        
        // Assert
        #expect(isFirstLaunch == true)
    }
    
    @Test("初回起動検出 - 2回目以降の起動")
    func testSubsequentLaunchDetection() async throws {
        // Arrange
        let testDefaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let service = TutorialService(userDefaults: testDefaults)
        
        // Act - 初回起動をマーク
        await service.markFirstLaunchCompleted()
        let isFirstLaunch = await service.isFirstLaunch()
        
        // Assert
        #expect(isFirstLaunch == false)
    }
    
    @Test("チュートリアル完了状態の管理")
    func testTutorialCompletionState() async throws {
        // Arrange
        let testDefaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let service = TutorialService(userDefaults: testDefaults)
        
        // Act & Assert - 初期状態
        let initialState = await service.isTutorialCompleted()
        #expect(initialState == false)
        
        // Act - チュートリアル完了をマーク
        await service.markTutorialCompleted()
        let completedState = await service.isTutorialCompleted()
        
        // Assert
        #expect(completedState == true)
    }
    
    @Test("チュートリアル進行状況の管理")
    func testTutorialProgressManagement() async throws {
        // Arrange
        let testDefaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let service = TutorialService(userDefaults: testDefaults)
        
        // Act & Assert - 初期状態
        let initialStep = await service.getCurrentTutorialStep()
        #expect(initialStep == .welcome)
        
        // Act - 次のステップに進む
        await service.setCurrentTutorialStep(.dowsingExplanation)
        let nextStep = await service.getCurrentTutorialStep()
        
        // Assert
        #expect(nextStep == .dowsingExplanation)
    }
    
    @Test("チュートリアルスキップ機能")
    func testTutorialSkipFunctionality() async throws {
        // Arrange
        let testDefaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let service = TutorialService(userDefaults: testDefaults)
        
        // Act - チュートリアルをスキップ
        await service.skipTutorial()
        
        // Assert - チュートリアルが完了状態になる
        let isCompleted = await service.isTutorialCompleted()
        #expect(isCompleted == true)
        
        // Assert - 最終ステップに設定される
        let currentStep = await service.getCurrentTutorialStep()
        #expect(currentStep == .completed)
    }
    
    @Test("チュートリアルリセット機能")
    func testTutorialResetFunctionality() async throws {
        // Arrange
        let testDefaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let service = TutorialService(userDefaults: testDefaults)
        
        // Act - チュートリアルを完了状態にする
        await service.markTutorialCompleted()
        await service.setCurrentTutorialStep(.completed)
        
        // Act - チュートリアルをリセット
        await service.resetTutorial()
        
        // Assert - 初期状態に戻る
        let isCompleted = await service.isTutorialCompleted()
        #expect(isCompleted == false)
        
        let currentStep = await service.getCurrentTutorialStep()
        #expect(currentStep == .welcome)
    }
    
    @Test("ヘルプアクセス設定の管理")
    func testHelpAccessSettings() async throws {
        // Arrange
        let testDefaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let service = TutorialService(userDefaults: testDefaults)
        
        // Act & Assert - 初期状態（ヘルプアクセス可能）
        let initialAccess = await service.isHelpAccessEnabled()
        #expect(initialAccess == true)
        
        // Act - ヘルプアクセスを無効にする
        await service.setHelpAccessEnabled(false)
        let disabledAccess = await service.isHelpAccessEnabled()
        
        // Assert
        #expect(disabledAccess == false)
        
        // Act - ヘルプアクセスを再度有効にする
        await service.setHelpAccessEnabled(true)
        let enabledAccess = await service.isHelpAccessEnabled()
        
        // Assert
        #expect(enabledAccess == true)
    }
    
    @Test("チュートリアルステップの順序検証")
    func testTutorialStepSequence() async throws {
        // Arrange
        let testDefaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let service = TutorialService(userDefaults: testDefaults)
        
        // Act & Assert - 各ステップを順番に進める
        await service.setCurrentTutorialStep(.welcome)
        #expect(await service.getCurrentTutorialStep() == .welcome)
        
        await service.setCurrentTutorialStep(.dowsingExplanation)
        #expect(await service.getCurrentTutorialStep() == .dowsingExplanation)
        
        await service.setCurrentTutorialStep(.sonarExplanation)
        #expect(await service.getCurrentTutorialStep() == .sonarExplanation)
        
        await service.setCurrentTutorialStep(.practiceMode)
        #expect(await service.getCurrentTutorialStep() == .practiceMode)
        
        await service.setCurrentTutorialStep(.completed)
        #expect(await service.getCurrentTutorialStep() == .completed)
    }
    
    @Test("永続化の確認")
    func testPersistence() async throws {
        // Arrange
        let testSuiteName = "test-\(UUID().uuidString)"
        let testDefaults1 = UserDefaults(suiteName: testSuiteName)!
        let service1 = TutorialService(userDefaults: testDefaults1)
        
        // Act - 最初のサービスインスタンスで設定
        await service1.markTutorialCompleted()
        await service1.setCurrentTutorialStep(.sonarExplanation)
        await service1.setHelpAccessEnabled(false)
        
        // Act - 新しいサービスインスタンスを作成
        let testDefaults2 = UserDefaults(suiteName: testSuiteName)!
        let service2 = TutorialService(userDefaults: testDefaults2)
        
        // Assert - 設定が永続化されている
        #expect(await service2.isTutorialCompleted() == true)
        #expect(await service2.getCurrentTutorialStep() == .sonarExplanation)
        #expect(await service2.isHelpAccessEnabled() == false)
    }
}