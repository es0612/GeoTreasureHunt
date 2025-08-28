import Foundation
import CoreLocation

/// Service responsible for exploration mechanics including distance calculation,
/// direction finding, and treasure discovery detection
public final class ExplorationService: ExplorationServiceProtocol {
    
    public init() {}
    
    // MARK: - Distance Calculation
    
    public func calculateDistance(from userLocation: CLLocation, to treasureCoordinate: CLLocationCoordinate2D) -> Double {
        // Validate coordinates
        guard CLLocationCoordinate2DIsValid(treasureCoordinate) else {
            return 0.0
        }
        
        let treasureLocation = CLLocation(
            latitude: treasureCoordinate.latitude,
            longitude: treasureCoordinate.longitude
        )
        
        return userLocation.distance(from: treasureLocation)
    }
    
    // MARK: - Direction Calculation (Dowsing)
    
    public func calculateDirection(from userLocation: CLLocation, to treasureCoordinate: CLLocationCoordinate2D) -> Double {
        // Validate coordinates
        guard CLLocationCoordinate2DIsValid(treasureCoordinate) else {
            return 0.0
        }
        
        let userCoordinate = userLocation.coordinate
        
        // Handle same location case
        if abs(userCoordinate.latitude - treasureCoordinate.latitude) < 0.0001 &&
           abs(userCoordinate.longitude - treasureCoordinate.longitude) < 0.0001 {
            return 0.0
        }
        
        // Calculate bearing using the forward azimuth formula
        let lat1 = userCoordinate.latitude * .pi / 180.0
        let lat2 = treasureCoordinate.latitude * .pi / 180.0
        let deltaLon = (treasureCoordinate.longitude - userCoordinate.longitude) * .pi / 180.0
        
        let y = sin(deltaLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)
        
        let bearing = atan2(y, x) * 180.0 / .pi
        
        // Normalize to 0-359 degrees
        return bearing < 0 ? bearing + 360.0 : bearing
    }
    
    // MARK: - Treasure Discovery
    
    public func checkTreasureDiscovery(userLocation: CLLocation, treasures: [Treasure]) -> Treasure? {
        guard !treasures.isEmpty else { return nil }
        
        // Find all discoverable treasures
        let discoverableTreasures = treasures.filter { treasure in
            treasure.isDiscoverableFrom(location: userLocation)
        }
        
        // Return the closest discoverable treasure
        return discoverableTreasures.min { treasure1, treasure2 in
            let distance1 = treasure1.distanceFrom(location: userLocation)
            let distance2 = treasure2.distanceFrom(location: userLocation)
            return distance1 < distance2
        }
    }
    
    // MARK: - Nearest Treasure Finding
    
    public func findNearestTreasure(from userLocation: CLLocation, in treasures: [Treasure]) -> Treasure? {
        guard !treasures.isEmpty else { return nil }
        
        return treasures.min { treasure1, treasure2 in
            let distance1 = treasure1.distanceFrom(location: userLocation)
            let distance2 = treasure2.distanceFrom(location: userLocation)
            return distance1 < distance2
        }
    }
}