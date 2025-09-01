import Testing
import Foundation
@testable import GeoSonarCore

@Suite("GameError Tests")
struct GameErrorTests {
    
    @Test("GameError provides localized error descriptions")
    func testGameErrorLocalizedDescriptions() {
        let locationPermissionError = GameError.locationPermissionDenied
        let locationServiceError = GameError.locationServiceUnavailable
        let mapDataError = GameError.mapDataCorrupted
        let treasureDataError = GameError.treasureDataMissing
        let gpsSignalError = GameError.gpsSignalWeak
        let compassError = GameError.compassUnavailable
        let audioError = GameError.audioServiceUnavailable
        let hapticError = GameError.hapticServiceUnavailable
        
        #expect(locationPermissionError.errorDescription == "位置情報の許可が必要です")
        #expect(locationServiceError.errorDescription == "位置情報サービスが利用できません")
        #expect(mapDataError.errorDescription == "マップデータが破損しています")
        #expect(treasureDataError.errorDescription == "宝のデータが見つかりません")
        #expect(gpsSignalError.errorDescription == "GPS信号が弱いです。屋外に移動してください")
        #expect(compassError.errorDescription == "コンパスが利用できません。ダウジングモードを無効にします")
        #expect(audioError.errorDescription == "オーディオサービスが利用できません")
        #expect(hapticError.errorDescription == "ハプティックフィードバックが利用できません")
    }
    
    @Test("GameError provides recovery suggestions")
    func testGameErrorRecoverySuggestions() {
        let locationPermissionError = GameError.locationPermissionDenied
        let gpsSignalError = GameError.gpsSignalWeak
        let mapDataError = GameError.mapDataCorrupted
        
        #expect(locationPermissionError.recoverySuggestion == "設定アプリで位置情報の許可を有効にしてください")
        #expect(gpsSignalError.recoverySuggestion == "屋外の開けた場所に移動してください")
        #expect(mapDataError.recoverySuggestion == "アプリを再起動してください")
    }
    
    @Test("GameError categorizes error severity")
    func testGameErrorSeverity() {
        #expect(GameError.locationPermissionDenied.severity == .critical)
        #expect(GameError.locationServiceUnavailable.severity == .critical)
        #expect(GameError.gpsSignalWeak.severity == .warning)
        #expect(GameError.mapDataCorrupted.severity == .error)
        #expect(GameError.treasureDataMissing.severity == .error)
        #expect(GameError.compassUnavailable.severity == .warning)
        #expect(GameError.audioServiceUnavailable.severity == .minor)
        #expect(GameError.hapticServiceUnavailable.severity == .minor)
    }
    
    @Test("GameError indicates if it's recoverable")
    func testGameErrorRecoverability() {
        #expect(GameError.locationPermissionDenied.isRecoverable == true)
        #expect(GameError.gpsSignalWeak.isRecoverable == true)
        #expect(GameError.mapDataCorrupted.isRecoverable == true)
        #expect(GameError.compassUnavailable.isRecoverable == false)
        #expect(GameError.audioServiceUnavailable.isRecoverable == true)
    }
}