import Foundation
import CoreLocation

/// Represents a treasure in the game
public struct Treasure: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let coordinate: CLLocationCoordinate2D
    public let name: String
    public let description: String
    public let points: Int
    public let discoveryRadius: Double // in meters
    
    public init(
        id: UUID,
        coordinate: CLLocationCoordinate2D,
        name: String,
        description: String,
        points: Int,
        discoveryRadius: Double
    ) {
        self.id = id
        self.coordinate = coordinate
        self.name = name
        self.description = description
        self.points = points
        self.discoveryRadius = discoveryRadius
    }
    
    // MARK: - Equatable Conformance
    
    public static func == (lhs: Treasure, rhs: Treasure) -> Bool {
        return lhs.id == rhs.id &&
               abs(lhs.coordinate.latitude - rhs.coordinate.latitude) < 0.0001 &&
               abs(lhs.coordinate.longitude - rhs.coordinate.longitude) < 0.0001 &&
               lhs.name == rhs.name &&
               lhs.description == rhs.description &&
               lhs.points == rhs.points &&
               abs(lhs.discoveryRadius - rhs.discoveryRadius) < 0.0001
    }
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case id, coordinate, name, description, points, discoveryRadius
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        let coordinateData = try container.decode(CodableCoordinate.self, forKey: .coordinate)
        self.coordinate = coordinateData.coordinate
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.points = try container.decode(Int.self, forKey: .points)
        self.discoveryRadius = try container.decode(Double.self, forKey: .discoveryRadius)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(CodableCoordinate(coordinate: coordinate), forKey: .coordinate)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(points, forKey: .points)
        try container.encode(discoveryRadius, forKey: .discoveryRadius)
    }
    
    // MARK: - Validation Methods
    
    /// Validates if the discovery radius is within acceptable bounds
    public func isValidDiscoveryRadius() -> Bool {
        return discoveryRadius > 0.0 && discoveryRadius <= 500.0
    }
    
    /// Validates if the coordinate is within valid geographical bounds
    public func isValidCoordinate() -> Bool {
        return coordinate.latitude >= -90.0 && coordinate.latitude <= 90.0 &&
               coordinate.longitude >= -180.0 && coordinate.longitude <= 180.0
    }
    
    /// Validates if the points value is positive
    public func isValidPoints() -> Bool {
        return points > 0
    }
    
    // MARK: - Distance and Discovery Methods
    
    /// Calculates the distance from a given location to this treasure
    /// - Parameter location: The user's current location
    /// - Returns: Distance in meters
    public func distanceFrom(location: CLLocation) -> Double {
        let treasureLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return location.distance(from: treasureLocation)
    }
    
    /// Determines if the treasure can be discovered from the given location
    /// - Parameter location: The user's current location
    /// - Returns: True if the user is within the discovery radius
    public func isDiscoverableFrom(location: CLLocation) -> Bool {
        let distance = distanceFrom(location: location)
        return distance <= discoveryRadius
    }
}