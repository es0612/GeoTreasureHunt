import XCTest
import GeoSonarCore
import GeoSonarUI

@MainActor
final class CompleteTreasureHuntFlowTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        
        // テスト用の環境変数を設定
        app.launchEnvironment["UITEST_MODE"] = "true"
        app.launchEnvironment["MOCK_LOCATION"] = "true"
        app.launchEnvironment["SKIP_LOCATION_PERMISSION"] = "true"
        
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }
    
    // MARK: - 完全な宝探しフローテスト
    
    @MainActor
    func testCompleteTreasureHuntFlow() throws {
        // 要件: 1.1, 1.2, 3.1, 3.2, 4.1, 5.1, 5.2, 6.1, 6.2
        
        // 1. アプリ起動とチュートリアル処理
        let skipTutorialButton = app.buttons["チュートリアルをスキップ"]
        if skipTutorialButton.exists {
            skipTutorialButton.tap()
        }
        
        // 2. マップ選択画面の表示確認
        let mapSelectionTitle = app.staticTexts["宝の地図を選択"]
        XCTAssertTrue(mapSelectionTitle.waitForExistence(timeout: 5.0), "マップ選択画面が表示されない")
        
        // 3. 利用可能なマップの確認
        let firstMap = app.cells.firstMatch
        XCTAssertTrue(firstMap.exists, "利用可能なマップが表示されない")
        
        // 4. マップ選択
        firstMap.tap()
        
        // 5. 探索画面への遷移確認
        let explorationView = app.otherElements["探索画面"]
        XCTAssertTrue(explorationView.waitForExistence(timeout: 3.0), "探索画面に遷移しない")
        
        // 6. モード切り替えテスト
        testModeToggling()
        
        // 7. ダウジングモードテスト
        testDowsingMode()
        
        // 8. ソナーモードテスト
        testSonarMode()
        
        // 9. 宝発見シミュレーション
        simulateTreasureDiscovery()
        
        // 10. ゲーム完了確認
        verifyGameCompletion()
    }
    
    private func testModeToggling() {
        // 要件: 5.1, 5.2
        
        // ダウジングモードボタンの確認
        let dowsingModeButton = app.buttons["ダウジングモード"]
        XCTAssertTrue(dowsingModeButton.exists, "ダウジングモードボタンが存在しない")
        
        // ソナーモードボタンの確認
        let sonarModeButton = app.buttons["ソナーモード"]
        XCTAssertTrue(sonarModeButton.exists, "ソナーモードボタンが存在しない")
        
        // ソナーモードに切り替え
        sonarModeButton.tap()
        
        // ソナーコントロールの表示確認
        let sonarButton = app.buttons["ソナーピング送信"]
        XCTAssertTrue(sonarButton.waitForExistence(timeout: 1.0), "ソナーボタンが表示されない")
        
        // ダウジングモードに戻す
        dowsingModeButton.tap()
        
        // コンパス表示の確認
        let compass = app.otherElements["ダウジングコンパス"]
        XCTAssertTrue(compass.waitForExistence(timeout: 1.0), "ダウジングコンパスが表示されない")
    }
    
    private func testDowsingMode() {
        // 要件: 3.1, 3.2, 3.3
        
        let dowsingModeButton = app.buttons["ダウジングモード"]
        dowsingModeButton.tap()
        
        // コンパス要素の存在確認
        let compass = app.otherElements["ダウジングコンパス"]
        XCTAssertTrue(compass.exists, "ダウジングコンパスが表示されない")
        
        // 方向インジケーターの存在確認
        let directionIndicator = app.images["方向インジケーター"]
        XCTAssertTrue(directionIndicator.exists, "方向インジケーターが表示されない")
        
        // 距離表示の確認
        let distanceLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '距離:'")).firstMatch
        XCTAssertTrue(distanceLabel.exists, "距離表示が見つからない")
    }
    
    private func testSonarMode() {
        // 要件: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6
        
        let sonarModeButton = app.buttons["ソナーモード"]
        sonarModeButton.tap()
        
        // ソナーボタンの存在確認
        let sonarButton = app.buttons["ソナーピング送信"]
        XCTAssertTrue(sonarButton.exists, "ソナーボタンが表示されない")
        
        // ソナーピング送信テスト
        sonarButton.tap()
        
        // フィードバック表示の確認（視覚的フィードバック）
        let feedbackIndicator = app.otherElements["ソナーフィードバック"]
        XCTAssertTrue(feedbackIndicator.waitForExistence(timeout: 2.0), "ソナーフィードバックが表示されない")
        
        // 距離に応じたフィードバック強度の確認
        let intensityLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '強度:'")).firstMatch
        XCTAssertTrue(intensityLabel.exists, "フィードバック強度が表示されない")
    }
    
    private func simulateTreasureDiscovery() {
        // 要件: 6.1, 6.2, 6.5
        
        // テスト用の宝発見をトリガー
        app.buttons["テスト用宝発見"].tap()
        
        // 発見アニメーションの確認
        let discoveryAnimation = app.otherElements["宝発見アニメーション"]
        XCTAssertTrue(discoveryAnimation.waitForExistence(timeout: 3.0), "宝発見アニメーションが表示されない")
        
        // 成功メッセージの確認
        let successMessage = app.alerts["宝を発見しました！"]
        XCTAssertTrue(successMessage.waitForExistence(timeout: 2.0), "成功メッセージが表示されない")
        
        // OKボタンをタップしてアラートを閉じる
        successMessage.buttons["OK"].tap()
        
        // スコア更新の確認
        let scoreLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'スコア:'")).firstMatch
        XCTAssertTrue(scoreLabel.exists, "スコア表示が見つからない")
        
        // スコアが0より大きいことを確認
        let scoreText = scoreLabel.label
        let scoreValue = Int(scoreText.components(separatedBy: ":").last?.trimmingCharacters(in: .whitespaces) ?? "0") ?? 0
        XCTAssertGreaterThan(scoreValue, 0, "スコアが更新されていない")
    }
    
    private func verifyGameCompletion() {
        // 要件: 6.6, 7.1, 7.2, 7.3, 7.4
        
        // 進捗表示の確認
        let progressLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '進捗:'")).firstMatch
        XCTAssertTrue(progressLabel.exists, "進捗表示が見つからない")
        
        // 発見済み宝物リストの確認
        let discoveredTreasuresList = app.tables["発見済み宝物"]
        if discoveredTreasuresList.exists {
            XCTAssertGreaterThan(discoveredTreasuresList.cells.count, 0, "発見済み宝物が記録されていない")
        }
    }
}