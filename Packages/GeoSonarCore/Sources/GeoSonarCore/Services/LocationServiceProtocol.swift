import CoreLocation
import Foundation
import Combine

/// Protocol defining the interface for location services
@available(iOS 15.0, macOS 12.0, *)
@MainActor
public protocol LocationServiceProtocol: ObservableObject {
    /// Current location of the user
    var currentLocation: CLLocation? { get }
    
    /// Current authorization status for location services
    var authorizationStatus: CLAuthorizationStatus { get }
    
    /// Whether location updates are currently active
    var isLocationUpdating: Bool { get }
    
    /// Whether GPS signal is weak or unavailable
    var isGPSSignalWeak: Bool { get }
    
    /// Request location permission from the user
    func requestLocationPermission()
    
    /// Start receiving location updates
    func startLocationUpdates() throws
    
    /// Stop receiving location updates
    func stopLocationUpdates()
}

/// Errors that can occur during location service operations
public enum LocationServiceError: LocalizedError {
    case permissionDenied
    case serviceUnavailable
    case gpsSignalWeak
    case locationUpdateFailed
    
    public var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "位置情報の許可が必要です"
        case .serviceUnavailable:
            return "位置情報サービスが利用できません"
        case .gpsSignalWeak:
            return "GPS信号が弱いです。屋外に移動してください"
        case .locationUpdateFailed:
            return "位置情報の更新に失敗しました"
        }
    }
}