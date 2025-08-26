import Foundation
import GeoSonarCore

/// Mock implementation of GameProgressRepository for testing purposes
public final class MockGameProgressRepository: GameProgressRepository, @unchecked Sendable {
    
    // MARK: - Mock Data Storage
    
    private var mockSessions: [UUID: GameSession] = [:]
    private var mockTotalScore: Int = 0
    private var shouldThrowError: GameProgressRepositoryError?
    
    // MARK: - Call Tracking
    
    private var saveProgressCallCount = 0
    private var loadProgressCallCount = 0
    private var getDiscoveredTreasuresCallCount = 0
    private var saveTotalScoreCallCount = 0
    private var getTotalScoreCallCount = 0
    private var clearAllProgressCallCount = 0
    private var hasProgressCallCount = 0
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - Mock Configuration Methods
    
    /// Sets a mock game session for a specific map ID
    /// - Parameters:
    ///   - session: The game session to store
    ///   - mapId: The map ID to associate with the session
    public func setMockSession(_ session: GameSession, for mapId: UUID) {
        mockSessions[mapId] = session
    }
    
    /// Sets the mock total score
    /// - Parameter score: The total score to return
    public func setMockTotalScore(_ score: Int) {
        mockTotalScore = score
    }
    
    /// Configures the repository to throw an error on the next operation
    /// - Parameter error: The error to throw
    public func setShouldThrowError(_ error: GameProgressRepositoryError?) {
        shouldThrowError = error
    }
    
    /// Resets all mock state and call counts
    public func reset() {
        mockSessions = [:]
        mockTotalScore = 0
        shouldThrowError = nil
        saveProgressCallCount = 0
        loadProgressCallCount = 0
        getDiscoveredTreasuresCallCount = 0
        saveTotalScoreCallCount = 0
        getTotalScoreCallCount = 0
        clearAllProgressCallCount = 0
        hasProgressCallCount = 0
    }
    
    // MARK: - Call Count Tracking
    
    public var saveProgressWasCalledCount: Int {
        return saveProgressCallCount
    }
    
    public var loadProgressWasCalledCount: Int {
        return loadProgressCallCount
    }
    
    public var getDiscoveredTreasuresWasCalledCount: Int {
        return getDiscoveredTreasuresCallCount
    }
    
    public var saveTotalScoreWasCalledCount: Int {
        return saveTotalScoreCallCount
    }
    
    public var getTotalScoreWasCalledCount: Int {
        return getTotalScoreCallCount
    }
    
    public var clearAllProgressWasCalledCount: Int {
        return clearAllProgressCallCount
    }
    
    public var hasProgressWasCalledCount: Int {
        return hasProgressCallCount
    }
    
    // MARK: - GameProgressRepository Implementation
    
    public func saveProgress(_ session: GameSession) async throws {
        saveProgressCallCount += 1
        
        if let error = shouldThrowError {
            throw error
        }
        
        mockSessions[session.mapId] = session
    }
    
    public func loadProgress(for mapId: UUID) async throws -> GameSession? {
        loadProgressCallCount += 1
        
        if let error = shouldThrowError {
            throw error
        }
        
        return mockSessions[mapId]
    }
    
    public func getDiscoveredTreasures(for mapId: UUID) async throws -> Set<UUID> {
        getDiscoveredTreasuresCallCount += 1
        
        if let error = shouldThrowError {
            throw error
        }
        
        return mockSessions[mapId]?.discoveredTreasures ?? Set<UUID>()
    }
    
    public func saveTotalScore(_ score: Int) async throws {
        saveTotalScoreCallCount += 1
        
        if let error = shouldThrowError {
            throw error
        }
        
        mockTotalScore = score
    }
    
    public func getTotalScore() async throws -> Int {
        getTotalScoreCallCount += 1
        
        if let error = shouldThrowError {
            throw error
        }
        
        return mockTotalScore
    }
    
    public func clearAllProgress() async throws {
        clearAllProgressCallCount += 1
        
        if let error = shouldThrowError {
            throw error
        }
        
        mockSessions.removeAll()
        mockTotalScore = 0
    }
    
    public func hasProgress(for mapId: UUID) async throws -> Bool {
        hasProgressCallCount += 1
        
        if let error = shouldThrowError {
            throw error
        }
        
        return mockSessions[mapId] != nil
    }
}