import XCTest
import GeoSonarCore
import GeoSonarUI

@MainActor
final class AccessibilityTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment["UITEST_MODE"] = "true"
        app.launchEnvironment["MOCK_LOCATION"] = "true"
        
        // アクセシビリティ機能を有効化
        app.launchEnvironment["ACCESSIBILITY_ENABLED"] = "true"
        
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }
    
    // MARK: - VoiceOver対応テスト
    
    @MainActor
    func testVoiceOverSupport() throws {
        // 要件: 5.1, 5.2 (アクセシビリティ対応)
        
        skipTutorialIfNeeded()
        
        // マップ選択画面のアクセシビリティ
        testMapSelectionAccessibility()
        
        selectFirstMap()
        
        // 探索画面のアクセシビリティ
        testExplorationViewAccessibility()
        
        // モード切り替えのアクセシビリティ
        testModeToggleAccessibility()
        
        // 設定画面のアクセシビリティ
        testSettingsAccessibility()
    }
    
    private func testMapSelectionAccessibility() {
        // マップ選択画面の要素にアクセシビリティラベルが設定されていることを確認
        
        let mapSelectionTitle = app.staticTexts["宝の地図を選択"]
        XCTAssertTrue(mapSelectionTitle.exists, "マップ選択タイトルが見つからない")
        XCTAssertFalse(mapSelectionTitle.accessibilityLabel?.isEmpty ?? true, "マップ選択タイトルにアクセシビリティラベルが設定されていない")
        
        // 各マップセルのアクセシビリティ
        let mapCells = app.cells
        XCTAssertGreaterThan(mapCells.count, 0, "マップセルが見つからない")
        
        for i in 0..<min(mapCells.count, 3) {
            let cell = mapCells.element(boundBy: i)
            XCTAssertTrue(cell.isAccessibilityElement, "マップセル\(i)がアクセシビリティ要素として認識されない")
            XCTAssertFalse(cell.accessibilityLabel?.isEmpty ?? true, "マップセル\(i)にアクセシビリティラベルが設定されていない")
            XCTAssertFalse(cell.accessibilityHint?.isEmpty ?? true, "マップセル\(i)にアクセシビリティヒントが設定されていない")
        }
    }
    
    private func testExplorationViewAccessibility() {
        // 探索画面の主要要素のアクセシビリティ確認
        
        let explorationView = app.otherElements["探索画面"]
        XCTAssertTrue(explorationView.exists, "探索画面が見つからない")
        
        // マップビューのアクセシビリティ
        let mapView = app.maps.firstMatch
        if mapView.exists {
            XCTAssertTrue(mapView.isAccessibilityElement, "マップビューがアクセシビリティ要素として認識されない")
            XCTAssertFalse(mapView.accessibilityLabel?.isEmpty ?? true, "マップビューにアクセシビリティラベルが設定されていない")
        }
        
        // 現在位置表示のアクセシビリティ
        let locationLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '現在位置'")).firstMatch
        if locationLabel.exists {
            XCTAssertTrue(locationLabel.isAccessibilityElement, "現在位置ラベルがアクセシビリティ要素として認識されない")
        }
        
        // 距離表示のアクセシビリティ
        let distanceLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '距離'")).firstMatch
        if distanceLabel.exists {
            XCTAssertTrue(distanceLabel.isAccessibilityElement, "距離ラベルがアクセシビリティ要素として認識されない")
            XCTAssertFalse(distanceLabel.accessibilityLabel?.isEmpty ?? true, "距離ラベルにアクセシビリティラベルが設定されていない")
        }
    }
    
    private func testModeToggleAccessibility() {
        // モード切り替えボタンのアクセシビリティ
        
        let dowsingButton = app.buttons["ダウジングモード"]
        XCTAssertTrue(dowsingButton.exists, "ダウジングモードボタンが見つからない")
        XCTAssertTrue(dowsingButton.isAccessibilityElement, "ダウジングモードボタンがアクセシビリティ要素として認識されない")
        XCTAssertFalse(dowsingButton.accessibilityLabel?.isEmpty ?? true, "ダウジングモードボタンにアクセシビリティラベルが設定されていない")
        XCTAssertFalse(dowsingButton.accessibilityHint?.isEmpty ?? true, "ダウジングモードボタンにアクセシビリティヒントが設定されていない")
        
        let sonarButton = app.buttons["ソナーモード"]
        XCTAssertTrue(sonarButton.exists, "ソナーモードボタンが見つからない")
        XCTAssertTrue(sonarButton.isAccessibilityElement, "ソナーモードボタンがアクセシビリティ要素として認識されない")
        XCTAssertFalse(sonarButton.accessibilityLabel?.isEmpty ?? true, "ソナーモードボタンにアクセシビリティラベルが設定されていない")
        XCTAssertFalse(sonarButton.accessibilityHint?.isEmpty ?? true, "ソナーモードボタンにアクセシビリティヒントが設定されていない")
        
        // モード切り替え時のアクセシビリティ状態変更
        sonarButton.tap()
        
        let sonarPingButton = app.buttons["ソナーピング送信"]
        if sonarPingButton.waitForExistence(timeout: 2.0) {
            XCTAssertTrue(sonarPingButton.isAccessibilityElement, "ソナーピングボタンがアクセシビリティ要素として認識されない")
            XCTAssertFalse(sonarPingButton.accessibilityLabel?.isEmpty ?? true, "ソナーピングボタンにアクセシビリティラベルが設定されていない")
        }
        
        // ダウジングモードに戻す
        dowsingButton.tap()
        
        let compass = app.otherElements["ダウジングコンパス"]
        if compass.waitForExistence(timeout: 2.0) {
            XCTAssertTrue(compass.isAccessibilityElement, "ダウジングコンパスがアクセシビリティ要素として認識されない")
            XCTAssertFalse(compass.accessibilityLabel?.isEmpty ?? true, "ダウジングコンパスにアクセシビリティラベルが設定されていない")
        }
    }
    
    private func testSettingsAccessibility() {
        // 設定画面のアクセシビリティ
        
        let settingsButton = app.buttons["設定"]
        if settingsButton.exists {
            XCTAssertTrue(settingsButton.isAccessibilityElement, "設定ボタンがアクセシビリティ要素として認識されない")
            settingsButton.tap()
            
            let settingsTitle = app.staticTexts["設定"]
            XCTAssertTrue(settingsTitle.waitForExistence(timeout: 3.0), "設定画面が表示されない")
            
            // 音量スライダーのアクセシビリティ
            let volumeSlider = app.sliders["音量"]
            if volumeSlider.exists {
                XCTAssertTrue(volumeSlider.isAccessibilityElement, "音量スライダーがアクセシビリティ要素として認識されない")
                XCTAssertFalse(volumeSlider.accessibilityLabel?.isEmpty ?? true, "音量スライダーにアクセシビリティラベルが設定されていない")
                XCTAssertFalse(volumeSlider.accessibilityValue?.isEmpty ?? true, "音量スライダーにアクセシビリティ値が設定されていない")
            }
            
            // ハプティックトグルのアクセシビリティ
            let hapticToggle = app.switches["ハプティックフィードバック"]
            if hapticToggle.exists {
                XCTAssertTrue(hapticToggle.isAccessibilityElement, "ハプティックトグルがアクセシビリティ要素として認識されない")
                XCTAssertFalse(hapticToggle.accessibilityLabel?.isEmpty ?? true, "ハプティックトグルにアクセシビリティラベルが設定されていない")
            }
            
            // 戻るボタンのアクセシビリティ
            let backButton = app.buttons["戻る"]
            XCTAssertTrue(backButton.exists, "戻るボタンが見つからない")
            XCTAssertTrue(backButton.isAccessibilityElement, "戻るボタンがアクセシビリティ要素として認識されない")
            backButton.tap()
        }
    }
    
    // MARK: - Dynamic Type対応テスト
    
    @MainActor
    func testDynamicTypeSupport() throws {
        // 要件: アクセシビリティ対応（文字サイズ調整）
        
        skipTutorialIfNeeded()
        
        // 大きな文字サイズでのテスト
        testWithDynamicTypeSize(.accessibilityExtraExtraExtraLarge)
        
        // 小さな文字サイズでのテスト
        testWithDynamicTypeSize(.extraSmall)
        
        // 標準サイズに戻す
        testWithDynamicTypeSize(.large)
    }
    
    private func testWithDynamicTypeSize(_ size: UIContentSizeCategory) {
        // Dynamic Typeサイズを変更してUIが適切に調整されることを確認
        
        // システム設定でDynamic Typeサイズを変更する代わりに、
        // アプリ内でのテキストサイズ調整機能をテスト
        
        let settingsButton = app.buttons["設定"]
        if settingsButton.exists {
            settingsButton.tap()
            
            // テキストサイズ設定があるかチェック
            let textSizeSlider = app.sliders["テキストサイズ"]
            if textSizeSlider.exists {
                // 最大サイズに設定
                textSizeSlider.adjust(toNormalizedSliderPosition: 1.0)
                
                // UIが適切に調整されることを確認
                let settingsTitle = app.staticTexts["設定"]
                XCTAssertTrue(settingsTitle.exists, "大きなテキストサイズでも設定タイトルが表示される")
                
                // 最小サイズに設定
                textSizeSlider.adjust(toNormalizedSliderPosition: 0.0)
                XCTAssertTrue(settingsTitle.exists, "小さなテキストサイズでも設定タイトルが表示される")
                
                // 標準サイズに戻す
                textSizeSlider.adjust(toNormalizedSliderPosition: 0.5)
            }
            
            let backButton = app.buttons["戻る"]
            backButton.tap()
        }
    }
    
    // MARK: - 色覚対応テスト
    
    @MainActor
    func testColorBlindnessSupport() throws {
        // 要件: アクセシビリティ対応（色覚サポート）
        
        skipTutorialIfNeeded()
        selectFirstMap()
        
        // 色に依存しない情報表示の確認
        testColorIndependentInformation()
        
        // ハイコントラストモードでのテスト
        testHighContrastMode()
    }
    
    private func testColorIndependentInformation() {
        // 色だけでなくテキストやアイコンでも情報が伝わることを確認
        
        // ダウジングモードでの方向表示
        let dowsingButton = app.buttons["ダウジングモード"]
        dowsingButton.tap()
        
        let compass = app.otherElements["ダウジングコンパス"]
        if compass.exists {
            // 方向が色だけでなく矢印やテキストでも示されることを確認
            let directionText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '方向'")).firstMatch
            XCTAssertTrue(directionText.exists, "方向情報がテキストでも表示されない")
        }
        
        // ソナーモードでの距離フィードバック
        let sonarButton = app.buttons["ソナーモード"]
        sonarButton.tap()
        
        let sonarPingButton = app.buttons["ソナーピング送信"]
        if sonarPingButton.exists {
            sonarPingButton.tap()
            
            // 距離情報が色だけでなくテキストでも表示されることを確認
            let distanceText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '距離'")).firstMatch
            XCTAssertTrue(distanceText.exists, "距離情報がテキストでも表示されない")
            
            let intensityText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '強度'")).firstMatch
            XCTAssertTrue(intensityText.exists, "フィードバック強度がテキストでも表示されない")
        }
    }
    
    private func testHighContrastMode() {
        // ハイコントラストモードでの表示確認
        
        app.launchEnvironment["HIGH_CONTRAST_MODE"] = "true"
        app.terminate()
        app.launch()
        
        skipTutorialIfNeeded()
        selectFirstMap()
        
        // 主要なUI要素が高コントラストモードでも見やすいことを確認
        let modeButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS 'モード'"))
        XCTAssertGreaterThan(modeButtons.count, 0, "モードボタンが高コントラストモードで表示されない")
        
        // 各ボタンが適切にコントラストを持っていることを確認
        // （実際のコントラスト値は自動テストでは測定困難だが、要素の存在は確認可能）
        for i in 0..<modeButtons.count {
            let button = modeButtons.element(boundBy: i)
            XCTAssertTrue(button.exists, "モードボタン\(i)が高コントラストモードで表示されない")
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