import Foundation

/// Protocol defining the interface for game progress data persistence
public protocol GameProgressRepository: Sendable {
    /// Saves the current game session progress
    /// - Parameter session: The game session to save
    /// - Throws: Repository errors if data cannot be saved
    func saveProgress(_ session: GameSession) async throws
    
    /// Loads the progress for a specific treasure map
    /// - Parameter mapId: The ID of the treasure map
    /// - Returns: The game session if found, nil if no progress exists
    /// - Throws: Repository errors if data cannot be loaded
    func loadProgress(for mapId: UUID) async throws -> GameSession?
    
    /// Retrieves the set of discovered treasures for a specific map
    /// - Parameter mapId: The ID of the treasure map
    /// - Returns: Set of discovered treasure IDs
    /// - Throws: Repository errors if data cannot be loaded
    func getDiscoveredTreasures(for mapId: UUID) async throws -> Set<UUID>
    
    /// Saves the total score across all game sessions
    /// - Parameter score: The total score to save
    /// - Throws: Repository errors if data cannot be saved
    func saveTotalScore(_ score: Int) async throws
    
    /// Retrieves the total score across all game sessions
    /// - Returns: The total score
    /// - Throws: Repository errors if data cannot be loaded
    func getTotalScore() async throws -> Int
    
    /// Clears all progress data (useful for reset functionality)
    /// - Throws: Repository errors if data cannot be cleared
    func clearAllProgress() async throws
    
    /// Checks if progress exists for a specific map
    /// - Parameter mapId: The ID of the treasure map
    /// - Returns: True if progress exists, false otherwise
    func hasProgress(for mapId: UUID) async throws -> Bool
}

/// Errors that can occur during game progress repository operations
public enum GameProgressRepositoryError: LocalizedError, Sendable {
    case saveFailed
    case loadFailed
    case dataCorrupted
    case storageUnavailable
    case invalidData
    
    public var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "進捗の保存に失敗しました"
        case .loadFailed:
            return "進捗の読み込みに失敗しました"
        case .dataCorrupted:
            return "進捗データが破損しています"
        case .storageUnavailable:
            return "ストレージが利用できません"
        case .invalidData:
            return "無効な進捗データです"
        }
    }
}