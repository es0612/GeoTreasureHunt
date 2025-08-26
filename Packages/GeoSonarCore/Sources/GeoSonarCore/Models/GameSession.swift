import Foundation

/// Represents an active or completed game session
public struct GameSession: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let mapId: UUID
    public let startTime: Date
    public var discoveredTreasures: Set<UUID>
    public var totalPoints: Int
    public var isActive: Bool
    
    public init(
        id: UUID,
        mapId: UUID,
        startTime: Date,
        discoveredTreasures: Set<UUID>,
        totalPoints: Int,
        isActive: Bool
    ) {
        self.id = id
        self.mapId = mapId
        self.startTime = startTime
        self.discoveredTreasures = discoveredTreasures
        self.totalPoints = totalPoints
        self.isActive = isActive
    }
    
    // MARK: - Treasure Discovery Methods
    
    /// Attempts to discover a treasure and add points
    /// - Parameters:
    ///   - treasureId: The ID of the treasure to discover
    ///   - points: The points to award for this treasure
    /// - Returns: True if the treasure was newly discovered, false if already discovered
    public mutating func discoverTreasure(_ treasureId: UUID, points: Int) -> Bool {
        guard !discoveredTreasures.contains(treasureId) else {
            return false // Already discovered
        }
        
        discoveredTreasures.insert(treasureId)
        totalPoints += points
        return true
    }
    
    /// Checks if a specific treasure has been discovered
    /// - Parameter treasureId: The ID of the treasure to check
    /// - Returns: True if the treasure has been discovered
    public func hasTreasureBeenDiscovered(_ treasureId: UUID) -> Bool {
        return discoveredTreasures.contains(treasureId)
    }
    
    // MARK: - Progress Tracking Methods
    
    /// Calculates the completion percentage based on total treasures
    /// - Parameter totalTreasures: Array of all treasure IDs in the map
    /// - Returns: Completion percentage (0.0 to 100.0)
    public func completionPercentage(totalTreasures: [UUID]) -> Double {
        guard !totalTreasures.isEmpty else { return 0.0 }
        
        let discoveredCount = totalTreasures.filter { discoveredTreasures.contains($0) }.count
        return (Double(discoveredCount) / Double(totalTreasures.count)) * 100.0
    }
    
    /// Calculates the duration of the current session
    /// - Returns: Duration in seconds since start time
    public func sessionDuration() -> TimeInterval {
        return Date().timeIntervalSince(startTime)
    }
    
    // MARK: - Session Management
    
    /// Ends the current game session
    public mutating func endSession() {
        isActive = false
    }
    
    // MARK: - Validation Methods
    
    /// Validates if the session is in a valid state
    /// - Returns: True if the session is valid
    public func isValidSession() -> Bool {
        return startTime <= Date() && totalPoints >= 0
    }
}