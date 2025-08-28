import Foundation
import CoreLocation

/// Protocol defining the exploration service interface for treasure hunting mechanics
public protocol ExplorationServiceProtocol: Sendable {
    
    /// Calculates the distance between a user location and a treasure coordinate
    /// - Parameters:
    ///   - userLocation: The user's current location
    ///   - treasureCoordinate: The coordinate of the treasure
    /// - Returns: Distance in meters
    func calculateDistance(from userLocation: CLLocation, to treasureCoordinate: CLLocationCoordinate2D) -> Double
    
    /// Calculates the direction (bearing) from user location to treasure coordinate
    /// - Parameters:
    ///   - userLocation: The user's current location
    ///   - treasureCoordinate: The coordinate of the treasure
    /// - Returns: Bearing in degrees (0-359, where 0 is North)
    func calculateDirection(from userLocation: CLLocation, to treasureCoordinate: CLLocationCoordinate2D) -> Double
    
    /// Checks if any treasure can be discovered from the current location
    /// - Parameters:
    ///   - userLocation: The user's current location
    ///   - treasures: Array of treasures to check
    /// - Returns: The first discoverable treasure, or nil if none are discoverable
    func checkTreasureDiscovery(userLocation: CLLocation, treasures: [Treasure]) -> Treasure?
    
    /// Finds the nearest treasure from the user's current location
    /// - Parameters:
    ///   - userLocation: The user's current location
    ///   - treasures: Array of treasures to search
    /// - Returns: The nearest treasure, or nil if the array is empty
    func findNearestTreasure(from userLocation: CLLocation, in treasures: [Treasure]) -> Treasure?
}