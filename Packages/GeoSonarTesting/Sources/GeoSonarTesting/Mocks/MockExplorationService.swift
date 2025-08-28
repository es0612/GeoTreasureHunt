import Foundation
import CoreLocation
import GeoSonarCore

/// Mock implementation of ExplorationServiceProtocol for testing purposes
public final class MockExplorationService: ExplorationServiceProtocol, @unchecked Sendable {
    
    // MARK: - Mock State
    
    public var mockDistance: Double = 0.0
    public var mockDirection: Double = 0.0
    public var mockDiscoveredTreasure: Treasure?
    public var mockNearestTreasure: Treasure?
    
    // MARK: - Call Tracking
    
    public private(set) var calculateDistanceCalls: [(CLLocation, CLLocationCoordinate2D)] = []
    public private(set) var calculateDirectionCalls: [(CLLocation, CLLocationCoordinate2D)] = []
    public private(set) var checkTreasureDiscoveryCalls: [(CLLocation, [Treasure])] = []
    public private(set) var findNearestTreasureCalls: [(CLLocation, [Treasure])] = []
    
    public init() {}
    
    // MARK: - ExplorationServiceProtocol Implementation
    
    public func calculateDistance(from userLocation: CLLocation, to treasureCoordinate: CLLocationCoordinate2D) -> Double {
        calculateDistanceCalls.append((userLocation, treasureCoordinate))
        return mockDistance
    }
    
    public func calculateDirection(from userLocation: CLLocation, to treasureCoordinate: CLLocationCoordinate2D) -> Double {
        calculateDirectionCalls.append((userLocation, treasureCoordinate))
        return mockDirection
    }
    
    public func checkTreasureDiscovery(userLocation: CLLocation, treasures: [Treasure]) -> Treasure? {
        checkTreasureDiscoveryCalls.append((userLocation, treasures))
        return mockDiscoveredTreasure
    }
    
    public func findNearestTreasure(from userLocation: CLLocation, in treasures: [Treasure]) -> Treasure? {
        findNearestTreasureCalls.append((userLocation, treasures))
        return mockNearestTreasure
    }
    
    // MARK: - Test Utilities
    
    /// Resets all mock state and call tracking
    public func reset() {
        mockDistance = 0.0
        mockDirection = 0.0
        mockDiscoveredTreasure = nil
        mockNearestTreasure = nil
        
        calculateDistanceCalls.removeAll()
        calculateDirectionCalls.removeAll()
        checkTreasureDiscoveryCalls.removeAll()
        findNearestTreasureCalls.removeAll()
    }
    
    /// Sets up mock to simulate a treasure discovery scenario
    public func setupTreasureDiscovery(treasure: Treasure, distance: Double, direction: Double) {
        mockDiscoveredTreasure = treasure
        mockNearestTreasure = treasure
        mockDistance = distance
        mockDirection = direction
    }
    
    /// Sets up mock to simulate no treasure discovery
    public func setupNoTreasureDiscovery(distance: Double, direction: Double) {
        mockDiscoveredTreasure = nil
        mockDistance = distance
        mockDirection = direction
    }
}