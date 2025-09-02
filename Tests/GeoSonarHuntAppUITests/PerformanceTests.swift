import XCTest
import GeoSonarCore
import GeoSonarUI

@MainActor
final class PerformanceTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment["UITEST_MODE"] = "true"
        app.launchEnvironment["MOCK_LOCATION"] = "true"
        app.launchEnvironment["PERFORMANCE_TEST"] = "true"
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }
    
    // MARK: - アプリ起動パフォーマンステスト
    
    @MainActor
    func testAppLaunchPerformance() throws {
        // 要件: 2.2, 2.4 (パフォーマンス最適化)
        
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.terminate()
            app.launch()
        }
        
        // アプリが3秒以内に起動することを確認
        let mainView = app.otherElements.firstMatch
        XCTAssertTrue(mainView.waitForExistence(timeout: 3.0), "アプリの起動が遅すぎる")
    }
    
    // MARK: - 画面遷移パフォーマンステスト
    
    @MainActor
    func testNavigationPerformance() throws {
        // 要件: UI応答性
        
        skipTutorialIfNeeded()
        
        measure(metrics: [XCTClockMetric()]) {
            // マップ選択から探索画面への遷移
            let firstMap = app.cells.firstMatch
            if firstMap.waitForExistence(timeout: 2.0) {
                firstMap.tap()
                
                let explorationView = app.otherElements["探索画面"]
                _ = explorationView.waitForExistence(timeout: 2.0)
                
                // 戻る
                let backButton = app.buttons["戻る"]
                if backButton.exists {
                    backButton.tap()
                }
            }
        }
    }
    
    // MARK: - モード切り替えパフォーマンステスト
    
    @MainActor
    func testModeTogglePerformance() throws {
        // 要件: 5.2 (0.2秒以内のインターフェース更新)
        
        skipTutorialIfNeeded()
        selectFirstMap()
        
        let dowsingButton = app.buttons["ダウジングモード"]
        let sonarButton = app.buttons["ソナーモード"]
        
        // モード切り替えの応答時間を測定
        measure(metrics: [XCTClockMetric()]) {
            for _ in 0..<10 {
                sonarButton.tap()
                
                // ソナーコントロールの表示を待つ
                let sonarPingButton = app.buttons["ソナーピング送信"]
                _ = sonarPingButton.waitForExistence(timeout: 0.5)
                
                dowsingButton.tap()
                
                // コンパスの表示を待つ
                let compass = app.otherElements["ダウジングコンパス"]
                _ = compass.waitForExistence(timeout: 0.5)
            }
        }
    }
    
    // MARK: - 位置更新パフォーマンステスト
    
    @MainActor
    func testLocationUpdatePerformance() throws {
        // 要件: 2.2 (1秒以内の位置更新)
        
        skipTutorialIfNeeded()
        selectFirstMap()
        
        // 位置更新の頻度と応答性をテスト
        measure(metrics: [XCTClockMetric()]) {
            // テスト用の位置更新トリガー
            let updateLocationButton = app.buttons["位置更新テスト"]
            if updateLocationButton.exists {
                for _ in 0..<5 {
                    updateLocationButton.tap()
                    
                    // 位置情報の更新を待つ
                    let locationLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '現在位置'")).firstMatch
                    _ = locationLabel.waitForExistence(timeout: 1.0)
                    
                    Thread.sleep(forTimeInterval: 0.2)
                }
            }
        }
    }
    
    // MARK: - ソナーフィードバックパフォーマンステスト
    
    @MainActor
    func testSonarFeedbackPerformance() throws {
        // 要件: 4.1, 4.2 (フィードバック応答性)
        
        skipTutorialIfNeeded()
        selectFirstMap()
        
        let sonarButton = app.buttons["ソナーモード"]
        sonarButton.tap()
        
        let sonarPingButton = app.buttons["ソナーピング送信"]
        XCTAssertTrue(sonarPingButton.waitForExistence(timeout: 2.0), "ソナーボタンが見つからない")
        
        // ソナーピング送信の応答時間を測定
        measure(metrics: [XCTClockMetric()]) {
            for _ in 0..<10 {
                sonarPingButton.tap()
                
                // フィードバック表示の確認
                let feedbackIndicator = app.otherElements["ソナーフィードバック"]
                _ = feedbackIndicator.waitForExistence(timeout: 1.0)
                
                Thread.sleep(forTimeInterval: 0.5) // フィードバック処理の完了を待つ
            }
        }
    }
    
    // MARK: - メモリ使用量テスト
    
    @MainActor
    func testMemoryUsage() throws {
        // 要件: 2.4 (メモリ使用量最適化)
        
        skipTutorialIfNeeded()
        selectFirstMap()
        
        // 長時間の使用をシミュレーション
        measure(metrics: [XCTMemoryMetric()]) {
            // 複数の操作を繰り返し実行
            for _ in 0..<20 {
                // モード切り替え
                app.buttons["ソナーモード"].tap()
                app.buttons["ダウジングモード"].tap()
                
                // ソナーピング送信
                app.buttons["ソナーモード"].tap()
                let sonarPingButton = app.buttons["ソナーピング送信"]
                if sonarPingButton.exists {
                    sonarPingButton.tap()
                    Thread.sleep(forTimeInterval: 0.1)
                }
                
                // 設定画面の開閉
                let settingsButton = app.buttons["設定"]
                if settingsButton.exists {
                    settingsButton.tap()
                    let backButton = app.buttons["戻る"]
                    if backButton.exists {
                        backButton.tap()
                    }
                }
            }
        }
    }
    
    // MARK: - CPU使用率テスト
    
    @MainActor
    func testCPUUsage() throws {
        // 要件: 2.2 (バッテリー消費最適化)
        
        skipTutorialIfNeeded()
        selectFirstMap()
        
        // CPU集約的な操作のパフォーマンステスト
        measure(metrics: [XCTCPUMetric()]) {
            // 連続的な距離計算をシミュレーション
            let calculateDistanceButton = app.buttons["距離計算テスト"]
            if calculateDistanceButton.exists {
                for _ in 0..<50 {
                    calculateDistanceButton.tap()
                    Thread.sleep(forTimeInterval: 0.02)
                }
            }
            
            // 連続的な方向計算をシミュレーション
            let calculateDirectionButton = app.buttons["方向計算テスト"]
            if calculateDirectionButton.exists {
                for _ in 0..<50 {
                    calculateDirectionButton.tap()
                    Thread.sleep(forTimeInterval: 0.02)
                }
            }
        }
    }
    
    // MARK: - ストレージI/Oパフォーマンステスト
    
    @MainActor
    func testStoragePerformance() throws {
        // 要件: 7.1, 7.2 (ローカル進捗追跡)
        
        skipTutorialIfNeeded()
        selectFirstMap()
        
        // 進捗保存の性能テスト
        measure(metrics: [XCTStorageMetric()]) {
            // 複数の宝発見をシミュレーション
            for i in 1...10 {
                let treasureButton = app.buttons["テスト用宝発見\(i)"]
                if treasureButton.exists {
                    treasureButton.tap()
                    
                    // 発見アラートの処理
                    let discoveryAlert = app.alerts["宝を発見しました！"]
                    if discoveryAlert.waitForExistence(timeout: 1.0) {
                        discoveryAlert.buttons["OK"].tap()
                    }
                }
            }
        }
    }
    
    // MARK: - 大量データ処理パフォーマンステスト
    
    @MainActor
    func testLargeDataSetPerformance() throws {
        // 要件: スケーラビリティ
        
        // 大量の宝データを含むマップでのテスト
        app.launchEnvironment["LARGE_DATASET_MODE"] = "true"
        app.terminate()
        app.launch()
        
        skipTutorialIfNeeded()
        
        // 大量データマップの読み込み性能
        measure(metrics: [XCTClockMetric()]) {
            let largeDataMap = app.cells.matching(NSPredicate(format: "label CONTAINS '大量データ'")).firstMatch
            if largeDataMap.exists {
                largeDataMap.tap()
                
                let explorationView = app.otherElements["探索画面"]
                _ = explorationView.waitForExistence(timeout: 5.0)
                
                // 戻る
                let backButton = app.buttons["戻る"]
                if backButton.exists {
                    backButton.tap()
                }
            }
        }
    }
    
    // MARK: - 並行処理パフォーマンステスト
    
    @MainActor
    func testConcurrentOperationsPerformance() throws {
        // 要件: Swift 6並行性
        
        skipTutorialIfNeeded()
        selectFirstMap()
        
        // 複数の並行操作の性能テスト
        measure(metrics: [XCTClockMetric()]) {
            // 位置更新、距離計算、フィードバック処理を同時実行
            let concurrentTestButton = app.buttons["並行処理テスト"]
            if concurrentTestButton.exists {
                for _ in 0..<5 {
                    concurrentTestButton.tap()
                    Thread.sleep(forTimeInterval: 0.5)
                }
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
}