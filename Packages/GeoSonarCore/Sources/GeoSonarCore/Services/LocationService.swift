import CoreLocation
import Foundation
import Combine

/// Real implementation of LocationServiceProtocol using CLLocationManager
@available(iOS 15.0, macOS 12.0, *)
@MainActor
public final class LocationService: NSObject, LocationServiceProtocol {
    
    // MARK: - Published Properties
    @Published public var currentLocation: CLLocation?
    @Published public var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published public var isLocationUpdating: Bool = false
    @Published public var isGPSSignalWeak: Bool = false
    
    // MARK: - Private Properties
    private let locationManager = CLLocationManager()
    private let accuracyThreshold: Double = 50.0 // GPS signal considered weak above this threshold
    
    // MARK: - Initialization
    
    public override init() {
        super.init()
        setupLocationManager()
    }
    
    // MARK: - Private Setup
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1.0 // Update every meter
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - LocationServiceProtocol Implementation
    
    public func requestLocationPermission() {
        guard authorizationStatus == .notDetermined else {
            return
        }
        
        #if os(iOS)
        locationManager.requestWhenInUseAuthorization()
        #else
        locationManager.requestAlwaysAuthorization()
        #endif
    }
    
    public func startLocationUpdates() throws {
        // Check if location services are enabled
        guard CLLocationManager.locationServicesEnabled() else {
            throw LocationServiceError.serviceUnavailable
        }
        
        // Check authorization status
        #if os(iOS)
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            throw LocationServiceError.permissionDenied
        }
        #else
        guard authorizationStatus == .authorizedAlways else {
            throw LocationServiceError.permissionDenied
        }
        #endif
        
        // Start location updates
        locationManager.startUpdatingLocation()
        isLocationUpdating = true
    }
    
    public func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        isLocationUpdating = false
    }
}

// MARK: - CLLocationManagerDelegate

@available(iOS 15.0, macOS 12.0, *)
extension LocationService: CLLocationManagerDelegate {
    
    public nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Update current location on main actor
        Task { @MainActor in
            currentLocation = location
            
            // Check GPS signal quality
            isGPSSignalWeak = location.horizontalAccuracy > accuracyThreshold || location.horizontalAccuracy < 0
        }
    }
    
    public nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle location errors
        if let clError = error as? CLError {
            Task { @MainActor in
                switch clError.code {
                case .denied:
                    // Permission was denied
                    stopLocationUpdates()
                case .locationUnknown:
                    // Location service was unable to determine location
                    isGPSSignalWeak = true
                case .network:
                    // Network error occurred
                    isGPSSignalWeak = true
                default:
                    // Other errors
                    break
                }
            }
        }
    }
    
    public nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            authorizationStatus = status
            
            switch status {
            case .denied, .restricted:
                // Stop location updates if permission is denied or restricted
                stopLocationUpdates()
            case .authorizedWhenInUse, .authorizedAlways:
                // Permission granted, can start location updates if needed
                break
            case .notDetermined:
                // Initial state, no action needed
                break
            @unknown default:
                // Handle future authorization statuses
                break
            }
        }
    }
}