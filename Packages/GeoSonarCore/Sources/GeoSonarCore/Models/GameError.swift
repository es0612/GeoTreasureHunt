import Foundation

/// Represents different types of errors that can occur in the Geo Sonar Hunt game
public enum GameError: Error, LocalizedError, Equatable, Hashable {
    case locationPermissionDenied
    case locationServiceUnavailable
    case mapDataCorrupted
    case treasureDataMissing
    case gpsSignalWeak
    case compassUnavailable
    case audioServiceUnavailable
    case hapticServiceUnavailable
    case networkUnavailable
    case dataCorruption(String)
    case unexpectedError(String)
    
    /// Unique identifier for each error type
    public var id: String {
        switch self {
        case .locationPermissionDenied:
            return "location_permission_denied"
        case .locationServiceUnavailable:
            return "location_service_unavailable"
        case .mapDataCorrupted:
            return "map_data_corrupted"
        case .treasureDataMissing:
            return "treasure_data_missing"
        case .gpsSignalWeak:
            return "gps_signal_weak"
        case .compassUnavailable:
            return "compass_unavailable"
        case .audioServiceUnavailable:
            return "audio_service_unavailable"
        case .hapticServiceUnavailable:
            return "haptic_service_unavailable"
        case .networkUnavailable:
            return "network_unavailable"
        case .dataCorruption:
            return "data_corruption"
        case .unexpectedError:
            return "unexpected_error"
        }
    }
    
    /// Localized error description for user display
    public var errorDescription: String? {
        switch self {
        case .locationPermissionDenied:
            return "位置情報の許可が必要です"
        case .locationServiceUnavailable:
            return "位置情報サービスが利用できません"
        case .mapDataCorrupted:
            return "マップデータが破損しています"
        case .treasureDataMissing:
            return "宝のデータが見つかりません"
        case .gpsSignalWeak:
            return "GPS信号が弱いです。屋外に移動してください"
        case .compassUnavailable:
            return "コンパスが利用できません。ダウジングモードを無効にします"
        case .audioServiceUnavailable:
            return "オーディオサービスが利用できません"
        case .hapticServiceUnavailable:
            return "ハプティックフィードバックが利用できません"
        case .networkUnavailable:
            return "ネットワーク接続が利用できません"
        case .dataCorruption(let details):
            return "データが破損しています: \(details)"
        case .unexpectedError(let details):
            return "予期しないエラーが発生しました: \(details)"
        }
    }
    
    /// Recovery suggestion for the user
    public var recoverySuggestion: String? {
        switch self {
        case .locationPermissionDenied:
            return "設定アプリで位置情報の許可を有効にしてください"
        case .locationServiceUnavailable:
            return "デバイスの位置情報サービスを有効にしてください"
        case .mapDataCorrupted:
            return "アプリを再起動してください"
        case .treasureDataMissing:
            return "アプリを再インストールしてください"
        case .gpsSignalWeak:
            return "屋外の開けた場所に移動してください"
        case .compassUnavailable:
            return "ソナーモードをご利用ください"
        case .audioServiceUnavailable:
            return "デバイスの音量設定を確認してください"
        case .hapticServiceUnavailable:
            return "視覚フィードバックをご利用ください"
        case .networkUnavailable:
            return "オフラインでも基本機能は利用できます"
        case .dataCorruption:
            return "アプリを再起動してください"
        case .unexpectedError:
            return "アプリを再起動してください"
        }
    }
    
    /// Error severity level
    public var severity: ErrorSeverity {
        switch self {
        case .locationPermissionDenied, .locationServiceUnavailable:
            return .critical
        case .mapDataCorrupted, .treasureDataMissing:
            return .error
        case .gpsSignalWeak, .compassUnavailable:
            return .warning
        case .audioServiceUnavailable, .hapticServiceUnavailable, .networkUnavailable:
            return .minor
        case .dataCorruption, .unexpectedError:
            return .error
        }
    }
    
    /// Whether the error can potentially be recovered from
    public var isRecoverable: Bool {
        switch self {
        case .locationPermissionDenied, .gpsSignalWeak, .mapDataCorrupted, 
             .audioServiceUnavailable, .hapticServiceUnavailable, .dataCorruption:
            return true
        case .locationServiceUnavailable, .treasureDataMissing, .compassUnavailable, 
             .networkUnavailable, .unexpectedError:
            return false
        }
    }
}

/// Error severity levels
public enum ErrorSeverity: String, CaseIterable {
    case critical = "critical"
    case error = "error"
    case warning = "warning"
    case minor = "minor"
    
    /// Priority level for error handling (higher number = higher priority)
    public var priority: Int {
        switch self {
        case .critical: return 4
        case .error: return 3
        case .warning: return 2
        case .minor: return 1
        }
    }
}

/// Degradation options for graceful error handling
public enum DegradationOption: String, CaseIterable {
    case disableDowsingMode = "disable_dowsing_mode"
    case showSonarModeOnly = "show_sonar_mode_only"
    case useVisualFeedbackOnly = "use_visual_feedback_only"
    case useHapticFeedbackOnly = "use_haptic_feedback_only"
    case useLastKnownLocation = "use_last_known_location"
    case useDefaultMap = "use_default_map"
    case disableAudio = "disable_audio"
    case disableHaptics = "disable_haptics"
}

/// Fallback mechanisms for error recovery
public enum FallbackMechanism: String, CaseIterable {
    case useLastKnownLocation = "use_last_known_location"
    case useDefaultMap = "use_default_map"
    case useHardcodedTreasures = "use_hardcoded_treasures"
    case switchToSonarMode = "switch_to_sonar_mode"
    case disableAudioFeedback = "disable_audio_feedback"
    case disableHapticFeedback = "disable_haptic_feedback"
    case showErrorMessage = "show_error_message"
}