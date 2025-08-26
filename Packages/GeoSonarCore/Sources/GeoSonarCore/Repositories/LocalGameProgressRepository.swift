import Foundation

/// Local implementation of GameProgressRepository that uses UserDefaults for persistence
public final class LocalGameProgressRepository: GameProgressRepository, @unchecked Sendable {
    
    // MARK: - Private Properties
    
    private let userDefaults: UserDefaults
    private let sessionsKey = "GeoSonarHunt.GameSessions"
    private let totalScoreKey = "GeoSonarHunt.TotalScore"
    
    // MARK: - Initialization
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - GameProgressRepository Implementation
    
    public func saveProgress(_ session: GameSession) async throws {
        do {
            // Load existing sessions
            var sessions = try loadAllSessions()
            
            // Update or add the session
            sessions[session.mapId] = session
            
            // Save back to UserDefaults
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(sessions)
            userDefaults.set(data, forKey: sessionsKey)
            
            // Update total score if session is completed
            if !session.isActive {
                let currentTotalScore = try await getTotalScore()
                let newTotalScore = max(currentTotalScore, session.totalPoints)
                try await saveTotalScore(newTotalScore)
            }
            
        } catch {
            throw GameProgressRepositoryError.saveFailed
        }
    }
    
    public func loadProgress(for mapId: UUID) async throws -> GameSession? {
        do {
            let sessions = try loadAllSessions()
            return sessions[mapId]
        } catch {
            throw GameProgressRepositoryError.loadFailed
        }
    }
    
    public func getDiscoveredTreasures(for mapId: UUID) async throws -> Set<UUID> {
        do {
            let sessions = try loadAllSessions()
            return sessions[mapId]?.discoveredTreasures ?? Set<UUID>()
        } catch {
            throw GameProgressRepositoryError.loadFailed
        }
    }
    
    public func saveTotalScore(_ score: Int) async throws {
        guard score >= 0 else {
            throw GameProgressRepositoryError.invalidData
        }
        
        userDefaults.set(score, forKey: totalScoreKey)
    }
    
    public func getTotalScore() async throws -> Int {
        return userDefaults.integer(forKey: totalScoreKey)
    }
    
    public func clearAllProgress() async throws {
        userDefaults.removeObject(forKey: sessionsKey)
        userDefaults.removeObject(forKey: totalScoreKey)
    }
    
    public func hasProgress(for mapId: UUID) async throws -> Bool {
        do {
            let sessions = try loadAllSessions()
            return sessions[mapId] != nil
        } catch {
            return false
        }
    }
    
    // MARK: - Private Methods
    
    private func loadAllSessions() throws -> [UUID: GameSession] {
        guard let data = userDefaults.data(forKey: sessionsKey) else {
            return [:]
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([UUID: GameSession].self, from: data)
        } catch {
            throw GameProgressRepositoryError.dataCorrupted
        }
    }
}