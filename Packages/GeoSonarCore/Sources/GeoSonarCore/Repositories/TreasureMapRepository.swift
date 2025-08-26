import Foundation

/// Protocol defining the interface for treasure map data access
public protocol TreasureMapRepository: Sendable {
    /// Retrieves all available treasure maps
    /// - Returns: Array of all treasure maps
    /// - Throws: Repository errors if data cannot be loaded
    func getAllMaps() async throws -> [TreasureMap]
    
    /// Retrieves a specific treasure map by its ID
    /// - Parameter id: The unique identifier of the treasure map
    /// - Returns: The treasure map if found, nil otherwise
    /// - Throws: Repository errors if data cannot be loaded
    func getMap(by id: UUID) async throws -> TreasureMap?
    
    /// Checks if a treasure map exists with the given ID
    /// - Parameter id: The unique identifier to check
    /// - Returns: True if the map exists, false otherwise
    func mapExists(id: UUID) async throws -> Bool
}

/// Errors that can occur during treasure map repository operations
public enum TreasureMapRepositoryError: LocalizedError, Sendable {
    case dataCorrupted
    case fileNotFound
    case invalidFormat
    case networkUnavailable
    
    public var errorDescription: String? {
        switch self {
        case .dataCorrupted:
            return "宝の地図データが破損しています"
        case .fileNotFound:
            return "宝の地図ファイルが見つかりません"
        case .invalidFormat:
            return "宝の地図データの形式が無効です"
        case .networkUnavailable:
            return "ネットワークが利用できません"
        }
    }
}