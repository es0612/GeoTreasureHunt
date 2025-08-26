import Foundation
import CoreLocation

/// Represents a treasure map containing multiple treasures
public struct TreasureMap: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let name: String
    public let description: String
    public let region: MapRegion
    public let treasures: [Treasure]
    public let difficulty: Difficulty
    
    public init(
        id: UUID,
        name: String,
        description: String,
        region: MapRegion,
        treasures: [Treasure],
        difficulty: Difficulty
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.region = region
        self.treasures = treasures
        self.difficulty = difficulty
    }
    
    // MARK: - Computed Properties
    
    /// Calculates the total points available in this treasure map
    public var totalPoints: Int {
        return treasures.reduce(0) { $0 + $1.points }
    }
    
    // MARK: - Validation Methods
    
    /// Validates if the map region has valid coordinates
    public func isValidRegion() -> Bool {
        let center = region.center
        return center.latitude >= -90.0 && center.latitude <= 90.0 &&
               center.longitude >= -180.0 && center.longitude <= 180.0 &&
               region.span.latitudeDelta > 0 && region.span.longitudeDelta > 0
    }
}