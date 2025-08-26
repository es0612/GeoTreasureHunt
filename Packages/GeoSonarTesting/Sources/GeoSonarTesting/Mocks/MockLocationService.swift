import CoreLocation
import Foundation
import Combine
import GeoSonarCore

/// Mock implementation of LocationServiceProtocol for testing
@available(iOS 15.0, macOS 12.0, *)
@MainActor
public final class MockLocationService: LocationServiceProtocol {
    
    // MARK: - Published Properties
    @Published public var currentLocation: CLLocation?
    @Published public var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published public var isLocationUpdating: Bool = false
    @Published public var isGPSSignalWeak: Bool = false
    
    // MARK: - Mock Control Properties
    public var shouldThrowOnStartUpdates: Bool = false
    public var errorToThrow: LocationServiceError?
    public var permissionRequestCallback: (() -> Void)?
    public var startUpdatesCallback: (() -> Void)?
    public var stopUpdatesCallback: (() -> Void)?
    
    // MARK: - Initialization
    public init() {}
    
    // MARK: - LocationServiceProtocol Implementation
    
    public func requestLocationPermission() {
        permissionRequestCallback?()
        // Simulate permission granted by default in tests
        #if os(iOS)
        authorizationStatus = .authorizedWhenInUse
        #else
        authorizationStatus = .authorizedAlways
        #endif
    }
    
    public func startLocationUpdates() throws {
        if shouldThrowOnStartUpdates, let error = errorToThrow {
            throw error
        }
        
        #if os(iOS)
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            throw LocationServiceError.permissionDenied
        }
        #else
        guard authorizationStatus == .authorizedAlways else {
            throw LocationServiceError.permissionDenied
        }
        #endif
        
        isLocationUpdating = true
        startUpdatesCallback?()
    }
    
    public func stopLocationUpdates() {
        isLocationUpdating = false
        stopUpdatesCallback?()
    }
    
    // MARK: - Test Helper Methods
    
    /// Simulate receiving a new location update
    public func simulateLocationUpdate(_ location: CLLocation) {
        currentLocation = location
        isGPSSignalWeak = location.horizontalAccuracy > 50.0
    }
    
    /// Simulate authorization status change
    public func simulateAuthorizationChange(_ status: CLAuthorizationStatus) {
        authorizationStatus = status
    }
    
    /// Simulate GPS signal weakness
    public func simulateWeakGPSSignal(_ isWeak: Bool = true) {
        isGPSSignalWeak = isWeak
    }
    
    /// Reset all mock state to defaults
    public func reset() {
        currentLocation = nil
        authorizationStatus = .notDetermined
        isLocationUpdating = false
        isGPSSignalWeak = false
        shouldThrowOnStartUpdates = false
        errorToThrow = nil
        permissionRequestCallback = nil
        startUpdatesCallback = nil
        stopUpdatesCallback = nil
    }
}