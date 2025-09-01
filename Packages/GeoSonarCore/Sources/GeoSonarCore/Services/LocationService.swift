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
    
    // MARK: - Performance Optimization Properties
    public var updateInterval: TimeInterval = 1.0
    private var batteryOptimizationMode: BatteryOptimizationMode = .balanced
    private var movementState: MovementState = .stationary
    private var lastLocation: CLLocation?
    private var lastMovementCheck: Date = Date()
    private var isBackgroundSuspended: Bool = false
    private var isSimulatingMovement: Bool = false
    
    // MARK: - Private Properties
    private let locationManager = CLLocationManager()
    private let accuracyThreshold: Double = 50.0 // GPS signal considered weak above this threshold
    private var updateTimer: Timer?
    
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
        updateTimer?.invalidate()
        updateTimer = nil
        isLocationUpdating = false
    }
    
    // MARK: - Performance Optimization Methods
    
    public func setBatteryOptimizationMode(_ mode: BatteryOptimizationMode) {
        batteryOptimizationMode = mode
        updateLocationManagerSettings()
    }
    
    public func simulateMovementState(_ state: MovementState) {
        movementState = state
        isSimulatingMovement = true
        updateLocationManagerSettings()
    }
    
    public func optimizeUpdateFrequency() async {
        // Only detect movement state if we're not in simulation mode
        if !isSimulatingMovement && currentLocation != nil && lastLocation != nil {
            await detectMovementState()
        }
        updateLocationManagerSettings()
    }
    
    public func suspendForBatteryOptimization() {
        guard !isBackgroundSuspended else { return }
        isBackgroundSuspended = true
        stopLocationUpdates()
    }
    
    public func resumeFromBatteryOptimization() {
        guard isBackgroundSuspended else { return }
        isBackgroundSuspended = false
        
        // For testing purposes, we'll simulate starting location updates
        // In a real app, this would check permissions and start updates
        #if os(iOS)
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
            isLocationUpdating = true
        }
        #else
        if authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
            isLocationUpdating = true
        }
        #endif
    }
    
    // MARK: - Private Performance Methods
    
    private func updateLocationManagerSettings() {
        let (accuracy, distanceFilter, interval) = getOptimizedSettings()
        
        locationManager.desiredAccuracy = accuracy
        locationManager.distanceFilter = distanceFilter
        updateInterval = interval
        
        // Restart location updates with new settings if currently updating
        if isLocationUpdating {
            locationManager.stopUpdatingLocation()
            locationManager.startUpdatingLocation()
        }
    }
    
    private func getOptimizedSettings() -> (accuracy: CLLocationAccuracy, distanceFilter: CLLocationDistance, interval: TimeInterval) {
        let baseSettings = getBatteryOptimizedSettings()
        let movementAdjustedSettings = adjustForMovement(baseSettings)
        return movementAdjustedSettings
    }
    
    private func getBatteryOptimizedSettings() -> (accuracy: CLLocationAccuracy, distanceFilter: CLLocationDistance, interval: TimeInterval) {
        switch batteryOptimizationMode {
        case .performance:
            return (kCLLocationAccuracyBest, 1.0, 1.0)
        case .balanced:
            return (kCLLocationAccuracyNearestTenMeters, 5.0, 2.0)
        case .aggressive:
            return (kCLLocationAccuracyHundredMeters, 10.0, 5.0)
        }
    }
    
    private func adjustForMovement(_ baseSettings: (accuracy: CLLocationAccuracy, distanceFilter: CLLocationDistance, interval: TimeInterval)) -> (accuracy: CLLocationAccuracy, distanceFilter: CLLocationDistance, interval: TimeInterval) {
        switch movementState {
        case .stationary:
            return (baseSettings.accuracy, baseSettings.distanceFilter, max(baseSettings.interval, 10.0))
        case .walking:
            return (baseSettings.accuracy, baseSettings.distanceFilter, min(max(baseSettings.interval, 2.0), 5.0))
        case .running:
            return (baseSettings.accuracy, max(baseSettings.distanceFilter / 2, 1.0), min(max(baseSettings.interval, 1.0), 2.0))
        }
    }
    
    private func detectMovementState() async {
        guard let currentLocation = currentLocation,
              let lastLocation = lastLocation else {
            movementState = .stationary
            return
        }
        
        let timeSinceLastCheck = Date().timeIntervalSince(lastMovementCheck)
        guard timeSinceLastCheck >= 5.0 else { return } // Check every 5 seconds minimum
        
        let distance = currentLocation.distance(from: lastLocation)
        let speed = distance / timeSinceLastCheck
        
        // Update movement state based on speed
        if speed < 0.5 { // Less than 0.5 m/s (1.8 km/h)
            movementState = .stationary
        } else if speed < 2.0 { // Less than 2 m/s (7.2 km/h)
            movementState = .walking
        } else {
            movementState = .running
        }
        
        self.lastLocation = currentLocation
        lastMovementCheck = Date()
    }
}

// MARK: - CLLocationManagerDelegate

@available(iOS 15.0, macOS 12.0, *)
extension LocationService: CLLocationManagerDelegate {
    
    public nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Update current location on main actor
        Task { @MainActor in
            // Store previous location for movement detection
            if currentLocation != nil {
                lastLocation = currentLocation
            }
            
            currentLocation = location
            
            // Check GPS signal quality
            isGPSSignalWeak = location.horizontalAccuracy > accuracyThreshold || location.horizontalAccuracy < 0
            
            // Optimize update frequency based on movement
            await optimizeUpdateFrequency()
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

// MARK: - Performance Optimization Types

@available(iOS 15.0, macOS 12.0, *)
public extension LocationService {
    
    enum BatteryOptimizationMode {
        case performance    // High frequency updates, high accuracy
        case balanced      // Medium frequency updates, balanced accuracy
        case aggressive    // Low frequency updates, lower accuracy to save battery
    }
    
    enum MovementState {
        case stationary    // User is not moving or moving very slowly
        case walking      // User is walking at normal pace
        case running      // User is running or moving quickly
    }
}