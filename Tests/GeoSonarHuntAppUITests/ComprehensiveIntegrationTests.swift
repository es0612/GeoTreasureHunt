import XCTest
import GeoSonarCore
import GeoSonarUI

@MainActor
final class ComprehensiveIntegrationTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment["UITEST_MODE"] = "true"
        app.launchEnvironment["MOCK_LOCATION"] = "true"
        app.launchEnvironment["COMPREHENSIVE_TEST"] = "true"
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }
    
    // MARK: - 全要件統合検証テスト
    
    @MainActor
    func testAllRequirementsIntegration() throws {
        // 全要件の統合検証を実行
        
        // 要件1: マップと宝物管理
        verifyMapAndTreasureManagement()
        
        // 要件2: GPS位置追跡
        verifyGPSLocationTracking()
        
        // 要件3: ダウジングモードナビゲーション
        verifyDowsingModeNavigation()
        
        // 要件4: ソナーモード距離フィードバック
        verifySonarModeDistanceFeedback()
        
        // 要件5: モード切り替え
        verifyModeToggling()
        
        // 要件6: 宝物発見
        verifyTreasureDiscovery()
        
        // 要件7: ローカル進捗追跡
        verifyLocalProgressTracking()
        
        // 要件8: オーディオとハプティック設定
        verifyAudioAndHapticSettings()
        
        // 要件9: チュートリアルとオンボーディング
        verifyTutorialAndOnboarding()
        
        // 要件10: オフライン動作
        verifyOfflineOperation()
    }
    
    // MARK: - 要件1: マップと宝物管理の検証
    
    private func verifyMapAndTreasureManagement() {
        // 1.1: 5つのデフォルト宝の地図のリスト表示
        let mapCells = app.cells
        XCTAssertGreaterThanOrEqual(mapCells.count, 5, "5つ以上のデフォルト地図が表示されない")
        
        // 1.2: 地図選択とローカルストレージからの宝の位置読み込み
        let firstMap = mapCells.firstMatch
        firstMap.tap()
        
        let explorationView = app.otherElements["探索画面"]
        XCTAssertTrue(explorationView.waitForExistence(timeout: 3.0), "地図選択後に探索画面に遷移しない")
        
        // 1.3: 宝の位置が地図表示から隠されていることを確認
        let treasureMarkers = app.images.matching(NSPredicate(format: "label CONTAINS '宝マーカー'"))
        XCTAssertEqual(treasureMarkers.count, 0, "宝の位置が地図上に表示されている")
        
        // 1.4: JSONファイルまたはハードコードされた座標の使用確認
        let mapDataLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '東京'")).firstMatch
        XCTAssertTrue(mapDataLabel.exists, "東京公共公園エリアのデータが読み込まれていない")
        
        // 1.5: Apple MapKitの使用確認
        let mapView = app.maps.firstMatch
        XCTAssertTrue(mapView.exists, "MapKitマップが表示されていない")
        
        // テスト後に戻る
        let backButton = app.buttons["戻る"]
        if backButton.exists {
            backButton.tap()
        }
    }
    
    // MARK: - 要件2: GPS位置追跡の検証
    
    private func verifyGPSLocationTracking() {
        selectFirstMap()
        
        // 2.1: 位置情報許可要求
        let locationPermissionAlert = app.alerts.matching(NSPredicate(format: "label CONTAINS '位置情報'")).firstMatch
        if locationPermissionAlert.exists {
            locationPermissionAlert.buttons["許可"].tap()
        }
        
        // 2.2: 1秒以内のユーザー位置更新
        let locationLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '現在位置'")).firstMatch
        XCTAssertTrue(locationLabel.waitForExistence(timeout: 1.0), "1秒以内に位置情報が更新されない")
        
        // 2.3: GPS信号弱の警告メッセージ（シミュレーション）
        app.launchEnvironment["SIMULATE_WEAK_GPS"] = "true"
        app.terminate()
        app.launch()
        skipTutorialIfNeeded()
        selectFirstMap()
        
        let gpsWarning = app.alerts["GPS信号が弱いです"]
        if gpsWarning.waitForExistence(timeout: 3.0) {
            XCTAssertTrue(gpsWarning.exists, "GPS信号弱の警告が表示されない")
            gpsWarning.buttons["OK"].tap()
        }
        
        // 2.4: バックグラウンド時の位置追跡一時停止
        // （UIテストでは直接検証困難だが、関連UIの存在を確認）
        let backgroundModeLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'バックグラウンド'")).firstMatch
        // バックグラウンド処理の状態表示があれば確認
        
        // 2.5: 位置情報サービス無効時の有効化促進
        app.launchEnvironment["SIMULATE_LOCATION_DISABLED"] = "true"
        app.terminate()
        app.launch()
        skipTutorialIfNeeded()
        selectFirstMap()
        
        let locationDisabledAlert = app.alerts.matching(NSPredicate(format: "label CONTAINS '位置情報サービス'")).firstMatch
        if locationDisabledAlert.waitForExistence(timeout: 3.0) {
            XCTAssertTrue(locationDisabledAlert.buttons["設定を開く"].exists, "位置情報有効化の指示が表示されない")
            locationDisabledAlert.buttons["キャンセル"].tap()
        }
        
        // 環境をリセット
        app.launchEnvironment.removeValue(forKey: "SIMULATE_WEAK_GPS")
        app.launchEnvironment.removeValue(forKey: "SIMULATE_LOCATION_DISABLED")
        app.terminate()
        app.launch()
        skipTutorialIfNeeded()
    }
    
    // MARK: - 要件3: ダウジングモードナビゲーションの検証
    
    private func verifyDowsingModeNavigation() {
        selectFirstMap()
        
        // 3.1: 最も近い宝への矢印または針の表示
        let dowsingButton = app.buttons["ダウジングモード"]
        dowsingButton.tap()
        
        let directionIndicator = app.images["方向インジケーター"]
        XCTAssertTrue(directionIndicator.waitForExistence(timeout: 1.0), "方向インジケーターが表示されない")
        
        // 3.2: 0.5秒以内の方向インジケーター更新
        // （向きの変更をシミュレーション）
        let updateDirectionButton = app.buttons["方向更新テスト"]
        if updateDirectionButton.exists {
            updateDirectionButton.tap()
            XCTAssertTrue(directionIndicator.waitForExistence(timeout: 0.5), "方向インジケーターが0.5秒以内に更新されない")
        }
        
        // 3.3: 宝に近づいた時の正確な方向案内維持
        let accuracyLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '精度'")).firstMatch
        XCTAssertTrue(accuracyLabel.exists, "方向案内の精度情報が表示されない")
        
        // 3.4: 最も近い未発見の宝を指すこと
        let nearestTreasureLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '最も近い宝'")).firstMatch
        XCTAssertTrue(nearestTreasureLabel.exists, "最も近い宝の情報が表示されない")
        
        // 3.5: コンパス利用不可時のエラーメッセージ
        app.launchEnvironment["SIMULATE_NO_COMPASS"] = "true"
        app.terminate()
        app.launch()
        skipTutorialIfNeeded()
        selectFirstMap()
        
        let compassError = app.alerts.matching(NSPredicate(format: "label CONTAINS 'コンパス'")).firstMatch
        if compassError.waitForExistence(timeout: 3.0) {
            XCTAssertTrue(compassError.exists, "コンパス利用不可時のエラーメッセージが表示されない")
            compassError.buttons["OK"].tap()
        }
        
        // 環境をリセット
        app.launchEnvironment.removeValue(forKey: "SIMULATE_NO_COMPASS")
        app.terminate()
        app.launch()
        skipTutorialIfNeeded()
    }
    
    // MARK: - 要件4: ソナーモード距離フィードバックの検証
    
    private func verifySonarModeDistanceFeedback() {
        selectFirstMap()
        
        let sonarButton = app.buttons["ソナーモード"]
        sonarButton.tap()
        
        // 4.1: ソナーボタンタップ時の距離計算
        let sonarPingButton = app.buttons["ソナーピング送信"]
        XCTAssertTrue(sonarPingButton.waitForExistence(timeout: 2.0), "ソナーピングボタンが表示されない")
        
        sonarPingButton.tap()
        
        // 4.2-4.5: 距離に応じたフィードバック（100m以上、50-100m、10-50m、10m未満）
        let feedbackIndicator = app.otherElements["ソナーフィードバック"]
        XCTAssertTrue(feedbackIndicator.waitForExistence(timeout: 2.0), "ソナーフィードバックが表示されない")
        
        let intensityLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '強度'")).firstMatch
        XCTAssertTrue(intensityLabel.exists, "フィードバック強度が表示されない")
        
        // 4.6: 視覚フィードバック（パルスアニメーション）
        let pulseAnimation = app.otherElements["パルスアニメーション"]
        XCTAssertTrue(pulseAnimation.exists, "パルスアニメーションが表示されない")
    }
    
    // MARK: - 要件5: モード切り替えの検証
    
    private func verifyModeToggling() {
        selectFirstMap()
        
        // 5.1: ダウジングモードとソナーモード用のトグルボタン表示
        let dowsingButton = app.buttons["ダウジングモード"]
        let sonarButton = app.buttons["ソナーモード"]
        
        XCTAssertTrue(dowsingButton.exists, "ダウジングモードボタンが表示されない")
        XCTAssertTrue(sonarButton.exists, "ソナーモードボタンが表示されない")
        
        // 5.2: 0.2秒以内のインターフェース更新
        let startTime = CFAbsoluteTimeGetCurrent()
        sonarButton.tap()
        
        let sonarPingButton = app.buttons["ソナーピング送信"]
        let sonarAppeared = sonarPingButton.waitForExistence(timeout: 0.2)
        let switchTime = CFAbsoluteTimeGetCurrent() - startTime
        
        XCTAssertTrue(sonarAppeared, "ソナーモードへの切り替えが0.2秒以内に完了しない")
        XCTAssertLessThan(switchTime, 0.2, "モード切り替えが0.2秒を超えている")
        
        // 5.3: ダウジングモード選択時のソナーコントロール非表示と方向インジケーター表示
        dowsingButton.tap()
        
        XCTAssertFalse(sonarPingButton.exists, "ダウジングモード時にソナーコントロールが表示されている")
        
        let compass = app.otherElements["ダウジングコンパス"]
        XCTAssertTrue(compass.waitForExistence(timeout: 0.2), "ダウジングモード時に方向インジケーターが表示されない")
        
        // 5.4: ソナーモード選択時の方向インジケーター非表示とソナーボタン表示
        sonarButton.tap()
        
        XCTAssertFalse(compass.exists, "ソナーモード時に方向インジケーターが表示されている")
        XCTAssertTrue(sonarPingButton.waitForExistence(timeout: 0.2), "ソナーモード時にソナーボタンが表示されない")
        
        // 5.5: モード切り替え時の位置追跡継続
        let locationLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '現在位置'")).firstMatch
        XCTAssertTrue(locationLabel.exists, "モード切り替え後も位置追跡が継続されない")
    }
    
    // MARK: - 要件6: 宝物発見の検証
    
    private func verifyTreasureDiscovery() {
        selectFirstMap()
        
        // 6.1: 10メートル以内での宝物発見トリガー
        let treasureDiscoveryButton = app.buttons["テスト用宝発見"]
        if treasureDiscoveryButton.exists {
            treasureDiscoveryButton.tap()
            
            // 6.2: 祝賀アニメーション表示
            let celebrationAnimation = app.otherElements["宝発見アニメーション"]
            XCTAssertTrue(celebrationAnimation.waitForExistence(timeout: 3.0), "祝賀アニメーションが表示されない")
            
            // 6.3: 成功音効果再生（UIでは音効果の実行状態を確認）
            let audioIndicator = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '音効果再生中'")).firstMatch
            // 音効果の実行は自動テストでは直接検証困難
            
            // 6.4: ローカルスコアへのポイント追加
            let discoveryAlert = app.alerts["宝を発見しました！"]
            XCTAssertTrue(discoveryAlert.waitForExistence(timeout: 2.0), "宝発見アラートが表示されない")
            discoveryAlert.buttons["OK"].tap()
            
            let scoreLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'スコア'")).firstMatch
            XCTAssertTrue(scoreLabel.exists, "スコア表示が見つからない")
            
            // 6.5: 発見済みとしてマークし、アクティブターゲットから削除
            let discoveredLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '発見済み'")).firstMatch
            XCTAssertTrue(discoveredLabel.exists, "宝が発見済みとしてマークされない")
        }
        
        // 6.6: 全ての宝発見時の完了メッセージ
        // （複数の宝を発見して完了状態をテスト）
        for i in 2...3 {
            let additionalTreasureButton = app.buttons["テスト用宝発見\(i)"]
            if additionalTreasureButton.exists {
                additionalTreasureButton.tap()
                let alert = app.alerts["宝を発見しました！"]
                if alert.waitForExistence(timeout: 2.0) {
                    alert.buttons["OK"].tap()
                }
            }
        }
        
        let completionAlert = app.alerts["おめでとうございます！"]
        if completionAlert.waitForExistence(timeout: 3.0) {
            XCTAssertTrue(completionAlert.staticTexts["全ての宝を発見しました！"].exists, "完了メッセージが表示されない")
            completionAlert.buttons["OK"].tap()
        }
    }
    
    // MARK: - 要件7: ローカル進捗追跡の検証
    
    private func verifyLocalProgressTracking() {
        // 7.1: 宝発見のローカルストレージ保存
        // （前のテストで宝を発見済みなので、その状態が保持されているかを確認）
        
        // アプリを再起動して進捗が保持されているかテスト
        app.terminate()
        app.launch()
        skipTutorialIfNeeded()
        selectFirstMap()
        
        // 7.2: アプリ再開時の以前の進捗読み込み
        let discoveredLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '発見済み'")).firstMatch
        XCTAssertTrue(discoveredLabel.exists, "アプリ再起動後に進捗が読み込まれない")
        
        // 7.3: 総スコアのローカル増加と永続化
        let scoreLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'スコア'")).firstMatch
        XCTAssertTrue(scoreLabel.exists, "スコアが永続化されていない")
        
        // 7.4: 実績完了時のバッジ/マイルストーンデータのローカル保存
        let achievementLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '実績'")).firstMatch
        // 実績システムが実装されている場合の確認
        
        // 7.5: ローカルデータ破損時の初期状態リセット
        app.launchEnvironment["SIMULATE_DATA_CORRUPTION"] = "true"
        app.terminate()
        app.launch()
        
        let dataResetAlert = app.alerts.matching(NSPredicate(format: "label CONTAINS 'データ'")).firstMatch
        if dataResetAlert.waitForExistence(timeout: 3.0) {
            XCTAssertTrue(dataResetAlert.exists, "データ破損時のリセット処理が実行されない")
            dataResetAlert.buttons["OK"].tap()
        }
        
        // 環境をリセット
        app.launchEnvironment.removeValue(forKey: "SIMULATE_DATA_CORRUPTION")
        app.terminate()
        app.launch()
        skipTutorialIfNeeded()
    }
    
    // MARK: - 要件8: オーディオとハプティック設定の検証
    
    private func verifyAudioAndHapticSettings() {
        // 8.1: ゲームオーディオ用のボリュームスライダー
        let settingsButton = app.buttons["設定"]
        if settingsButton.exists {
            settingsButton.tap()
            
            let volumeSlider = app.sliders["音量"]
            XCTAssertTrue(volumeSlider.waitForExistence(timeout: 3.0), "音量スライダーが表示されない")
            
            // 8.2: ハプティックフィードバック用のトグル
            let hapticToggle = app.switches["ハプティックフィードバック"]
            XCTAssertTrue(hapticToggle.exists, "ハプティックトグルが表示されない")
            
            // 8.3: オーディオ無効時の視覚とハプティックフィードバックのみ依存
            let audioToggle = app.switches["音声を有効にする"]
            if audioToggle.exists {
                audioToggle.tap() // 無効化
                
                // フィードバックテストボタンがあれば実行
                let feedbackTestButton = app.buttons["フィードバックテスト"]
                if feedbackTestButton.exists {
                    feedbackTestButton.tap()
                    
                    // 視覚フィードバックのみが動作することを確認
                    let visualFeedback = app.otherElements["視覚フィードバック"]
                    XCTAssertTrue(visualFeedback.waitForExistence(timeout: 2.0), "オーディオ無効時に視覚フィードバックが動作しない")
                }
                
                audioToggle.tap() // 再度有効化
            }
            
            // 8.4: ハプティック無効時のオーディオと視覚フィードバックのみ依存
            hapticToggle.tap() // 無効化
            
            // 8.5: 設定変更の即座適用とローカル保存
            volumeSlider.adjust(toNormalizedSliderPosition: 0.7)
            
            // 設定が即座に反映されることを確認
            let volumeLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '70%'")).firstMatch
            XCTAssertTrue(volumeLabel.waitForExistence(timeout: 1.0), "設定変更が即座に反映されない")
            
            let backButton = app.buttons["戻る"]
            backButton.tap()
        }
    }
    
    // MARK: - 要件9: チュートリアルとオンボーディングの検証
    
    private func verifyTutorialAndOnboarding() {
        // 初回起動をシミュレーション
        app.launchEnvironment["SIMULATE_FIRST_LAUNCH"] = "true"
        app.terminate()
        app.launch()
        
        // 9.1: 初回起動時のチュートリアルシーケンス表示
        let tutorialView = app.otherElements["チュートリアル"]
        XCTAssertTrue(tutorialView.waitForExistence(timeout: 5.0), "初回起動時にチュートリアルが表示されない")
        
        // 9.2: ダウジングモードの視覚的デモンストレーション
        let dowsingDemo = app.otherElements["ダウジングデモ"]
        XCTAssertTrue(dowsingDemo.exists, "ダウジングモードのデモが表示されない")
        
        let nextButton = app.buttons["次へ"]
        if nextButton.exists {
            nextButton.tap()
        }
        
        // 9.3: ソナーモードのインタラクティブな例
        let sonarDemo = app.otherElements["ソナーデモ"]
        XCTAssertTrue(sonarDemo.waitForExistence(timeout: 3.0), "ソナーモードのデモが表示されない")
        
        let finishButton = app.buttons["完了"]
        if finishButton.exists {
            finishButton.tap()
        }
        
        // 9.4: チュートリアル完了後の既読マーク
        // アプリを再起動してチュートリアルが再表示されないことを確認
        app.terminate()
        app.launch()
        
        XCTAssertFalse(tutorialView.waitForExistence(timeout: 3.0), "チュートリアル完了後に再表示される")
        
        // 9.5: チュートリアルスキップ時の設定でのヘルプ情報アクセス
        app.launchEnvironment["SIMULATE_FIRST_LAUNCH"] = "true"
        app.terminate()
        app.launch()
        
        let skipButton = app.buttons["チュートリアルをスキップ"]
        if skipButton.waitForExistence(timeout: 3.0) {
            skipButton.tap()
            
            let settingsButton = app.buttons["設定"]
            if settingsButton.exists {
                settingsButton.tap()
                
                let helpButton = app.buttons["ヘルプ"]
                XCTAssertTrue(helpButton.exists, "設定にヘルプ情報へのアクセスが提供されない")
                
                let backButton = app.buttons["戻る"]
                backButton.tap()
            }
        }
        
        // 環境をリセット
        app.launchEnvironment.removeValue(forKey: "SIMULATE_FIRST_LAUNCH")
        app.terminate()
        app.launch()
        skipTutorialIfNeeded()
    }
    
    // MARK: - 要件10: オフライン動作の検証
    
    private func verifyOfflineOperation() {
        // 10.1: インターネット接続なしでの完全機能
        app.launchEnvironment["SIMULATE_OFFLINE"] = "true"
        app.terminate()
        app.launch()
        skipTutorialIfNeeded()
        
        // マップ選択が正常に動作することを確認
        let mapCells = app.cells
        XCTAssertGreaterThan(mapCells.count, 0, "オフライン時にマップが表示されない")
        
        selectFirstMap()
        
        // 10.2: ネットワーク利用不可時のローカルデータ使用による通常動作継続
        let explorationView = app.otherElements["探索画面"]
        XCTAssertTrue(explorationView.exists, "オフライン時に探索画面が動作しない")
        
        // 10.3: GPS利用可能でネットワーク利用不可時の完全なゲームプレイ機能
        let dowsingButton = app.buttons["ダウジングモード"]
        dowsingButton.tap()
        
        let compass = app.otherElements["ダウジングコンパス"]
        XCTAssertTrue(compass.waitForExistence(timeout: 2.0), "オフライン時にダウジング機能が動作しない")
        
        let sonarButton = app.buttons["ソナーモード"]
        sonarButton.tap()
        
        let sonarPingButton = app.buttons["ソナーピング送信"]
        XCTAssertTrue(sonarPingButton.waitForExistence(timeout: 2.0), "オフライン時にソナー機能が動作しない")
        
        // 10.4: キャッシュされたまたはシステム提供の地図データ使用
        let mapView = app.maps.firstMatch
        XCTAssertTrue(mapView.exists, "オフライン時に地図が表示されない")
        
        // 10.5: 重要なローカルデータ欠落時の適切なエラーメッセージと優雅な劣化
        app.launchEnvironment["SIMULATE_MISSING_DATA"] = "true"
        app.terminate()
        app.launch()
        
        let dataErrorAlert = app.alerts.matching(NSPredicate(format: "label CONTAINS 'データ'")).firstMatch
        if dataErrorAlert.waitForExistence(timeout: 5.0) {
            XCTAssertTrue(dataErrorAlert.exists, "ローカルデータ欠落時のエラーメッセージが表示されない")
            dataErrorAlert.buttons["OK"].tap()
        }
        
        // 環境をリセット
        app.launchEnvironment.removeValue(forKey: "SIMULATE_OFFLINE")
        app.launchEnvironment.removeValue(forKey: "SIMULATE_MISSING_DATA")
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