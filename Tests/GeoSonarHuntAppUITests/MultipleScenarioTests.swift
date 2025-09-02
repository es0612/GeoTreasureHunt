import XCTest
import GeoSonarCore
import GeoSonarUI

@MainActor
final class MultipleScenarioTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment["UITEST_MODE"] = "true"
        app.launchEnvironment["MOCK_LOCATION"] = "true"
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }
    
    // MARK: - 複数宝発見シナリオ
    
    @MainActor
    func testMultipleTreasureDiscoveryScenario() throws {
        // 要件: 1.1, 1.2, 6.1, 6.2, 6.5, 7.1, 7.2
        
        skipTutorialIfNeeded()
        selectFirstMap()
        
        // 最初の宝を発見
        discoverTreasure(treasureIndex: 1)
        verifyTreasureDiscovered(expectedCount: 1)
        
        // 2番目の宝を発見
        discoverTreasure(treasureIndex: 2)
        verifyTreasureDiscovered(expectedCount: 2)
        
        // 3番目の宝を発見
        discoverTreasure(treasureIndex: 3)
        verifyTreasureDiscovered(expectedCount: 3)
        
        // 全ての宝が発見された場合の完了メッセージ確認
        let completionAlert = app.alerts["おめでとうございます！"]
        if completionAlert.waitForExistence(timeout: 3.0) {
            XCTAssertTrue(completionAlert.staticTexts["全ての宝を発見しました！"].exists, "完了メッセージが正しくない")
            completionAlert.buttons["OK"].tap()
        }
    }
    
    // MARK: - 設定変更シナリオ
    
    @MainActor
    func testSettingsChangeScenario() throws {
        // 要件: 8.1, 8.2, 8.3, 8.4, 8.5
        
        skipTutorialIfNeeded()
        
        // 設定画面を開く
        let settingsButton = app.buttons["設定"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5.0), "設定ボタンが見つからない")
        settingsButton.tap()
        
        // 設定画面の表示確認
        let settingsTitle = app.staticTexts["設定"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 3.0), "設定画面が表示されない")
        
        // オーディオ設定のテスト
        testAudioSettings()
        
        // ハプティック設定のテスト
        testHapticSettings()
        
        // 設定の即座反映テスト
        testImmediateSettingsApplication()
        
        // 設定画面を閉じる
        let backButton = app.buttons["戻る"]
        backButton.tap()
    }
    
    private func testAudioSettings() {
        // 要件: 8.1, 8.3, 8.5
        
        // ボリュームスライダーの確認
        let volumeSlider = app.sliders["音量"]
        XCTAssertTrue(volumeSlider.exists, "音量スライダーが見つからない")
        
        // 音量を変更
        volumeSlider.adjust(toNormalizedSliderPosition: 0.7)
        
        // 音量値の表示確認
        let volumeLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '音量: 70%'")).firstMatch
        XCTAssertTrue(volumeLabel.waitForExistence(timeout: 1.0), "音量値が正しく表示されない")
        
        // 音声無効化トグルのテスト
        let audioToggle = app.switches["音声を有効にする"]
        if audioToggle.exists {
            let initialState = audioToggle.value as? String == "1"
            audioToggle.tap()
            
            // 状態が変更されたことを確認
            let newState = audioToggle.value as? String == "1"
            XCTAssertNotEqual(initialState, newState, "音声トグルの状態が変更されない")
        }
    }
    
    private func testHapticSettings() {
        // 要件: 8.2, 8.4, 8.5
        
        // ハプティックフィードバックトグルの確認
        let hapticToggle = app.switches["ハプティックフィードバック"]
        XCTAssertTrue(hapticToggle.exists, "ハプティックトグルが見つからない")
        
        let initialState = hapticToggle.value as? String == "1"
        hapticToggle.tap()
        
        // 状態が変更されたことを確認
        let newState = hapticToggle.value as? String == "1"
        XCTAssertNotEqual(initialState, newState, "ハプティックトグルの状態が変更されない")
        
        // ハプティック強度設定（存在する場合）
        let intensitySlider = app.sliders["ハプティック強度"]
        if intensitySlider.exists {
            intensitySlider.adjust(toNormalizedSliderPosition: 0.5)
        }
    }
    
    private func testImmediateSettingsApplication() {
        // 要件: 8.5
        
        // 設定変更後、即座に適用されることをテスト
        // テスト用のフィードバックボタンがある場合
        let testFeedbackButton = app.buttons["フィードバックテスト"]
        if testFeedbackButton.exists {
            testFeedbackButton.tap()
            
            // フィードバックが設定に応じて動作することを確認
            // （実際のフィードバックは自動テストでは検証困難だが、UIの反応は確認可能）
            let feedbackIndicator = app.otherElements["フィードバック実行中"]
            XCTAssertTrue(feedbackIndicator.waitForExistence(timeout: 2.0), "フィードバックが実行されない")
        }
    }
    
    // MARK: - エラー処理シナリオ
    
    @MainActor
    func testErrorHandlingScenario() throws {
        // 要件: 2.3, 2.5, 10.4, 10.5
        
        skipTutorialIfNeeded()
        
        // GPS信号弱のシミュレーション
        app.launchEnvironment["SIMULATE_WEAK_GPS"] = "true"
        app.terminate()
        app.launch()
        
        skipTutorialIfNeeded()
        selectFirstMap()
        
        // GPS信号弱の警告表示確認
        let gpsWarning = app.alerts["GPS信号が弱いです"]
        if gpsWarning.waitForExistence(timeout: 5.0) {
            XCTAssertTrue(gpsWarning.staticTexts["屋外に移動してください"].exists, "GPS警告メッセージが正しくない")
            gpsWarning.buttons["OK"].tap()
        }
        
        // 位置情報許可拒否のシミュレーション
        testLocationPermissionDenied()
        
        // データ破損のシミュレーション
        testDataCorruptionHandling()
    }
    
    private func testLocationPermissionDenied() {
        // 要件: 2.1, 2.5
        
        app.launchEnvironment["SIMULATE_LOCATION_DENIED"] = "true"
        app.terminate()
        app.launch()
        
        skipTutorialIfNeeded()
        selectFirstMap()
        
        // 位置情報許可要求の確認
        let locationAlert = app.alerts["位置情報の許可が必要です"]
        if locationAlert.waitForExistence(timeout: 5.0) {
            XCTAssertTrue(locationAlert.staticTexts["設定から位置情報を有効にしてください"].exists, "位置情報エラーメッセージが正しくない")
            locationAlert.buttons["設定を開く"].tap()
        }
    }
    
    private func testDataCorruptionHandling() {
        // 要件: 1.4, 1.5, 10.5
        
        app.launchEnvironment["SIMULATE_DATA_CORRUPTION"] = "true"
        app.terminate()
        app.launch()
        
        // データ破損エラーの確認
        let dataError = app.alerts["データエラー"]
        if dataError.waitForExistence(timeout: 5.0) {
            XCTAssertTrue(dataError.staticTexts["アプリを再起動してください"].exists, "データエラーメッセージが正しくない")
            dataError.buttons["再起動"].tap()
        }
    }
    
    // MARK: - パフォーマンステストシナリオ
    
    @MainActor
    func testPerformanceScenario() throws {
        // 要件: 2.2, 2.4
        
        skipTutorialIfNeeded()
        selectFirstMap()
        
        // 連続的なモード切り替えのパフォーマンステスト
        measure {
            for _ in 0..<10 {
                app.buttons["ソナーモード"].tap()
                app.buttons["ダウジングモード"].tap()
            }
        }
        
        // 連続的なソナーピング送信のパフォーマンステスト
        app.buttons["ソナーモード"].tap()
        
        measure {
            for _ in 0..<5 {
                app.buttons["ソナーピング送信"].tap()
                Thread.sleep(forTimeInterval: 0.5) // フィードバック処理の完了を待つ
            }
        }
    }
    
    // MARK: - ヘルパーメソッド
    
    private func skipTutorialIfNeeded() {
        let skipButton = app.buttons["チュートリアルをスキップ"]
        if skipButton.waitForExistence(timeout: 3.0) {
            skipButton.tap()
        }
    }
    
    private func selectFirstMap() {
        let firstMap = app.cells.firstMatch
        XCTAssertTrue(firstMap.waitForExistence(timeout: 5.0), "マップが見つからない")
        firstMap.tap()
        
        let explorationView = app.otherElements["探索画面"]
        XCTAssertTrue(explorationView.waitForExistence(timeout: 3.0), "探索画面に遷移しない")
    }
    
    private func discoverTreasure(treasureIndex: Int) {
        let treasureButton = app.buttons["テスト用宝発見\(treasureIndex)"]
        if treasureButton.exists {
            treasureButton.tap()
            
            let discoveryAlert = app.alerts["宝を発見しました！"]
            if discoveryAlert.waitForExistence(timeout: 3.0) {
                discoveryAlert.buttons["OK"].tap()
            }
        }
    }
    
    private func verifyTreasureDiscovered(expectedCount: Int) {
        let scoreLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'スコア:'")).firstMatch
        XCTAssertTrue(scoreLabel.exists, "スコア表示が見つからない")
        
        let discoveredCountLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '発見数: \(expectedCount)'")).firstMatch
        XCTAssertTrue(discoveredCountLabel.exists, "発見数が正しく表示されない")
    }
}