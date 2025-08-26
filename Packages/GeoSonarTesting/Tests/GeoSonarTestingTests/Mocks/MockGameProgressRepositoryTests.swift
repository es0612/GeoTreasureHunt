import Testing
import Foundation
import CoreLocation
import GeoSonarTesting
import GeoSonarCore

@Suite("MockGameProgressRepository Tests")
struct MockGameProgressRepositoryTests {
    
    @Test("MockGameProgressRepository should save and load progress")
    func testSaveAndLoadProgress() async throws {
        let mockRepo = MockGameProgressRepository()
        
        let mapId = UUID()
        let session = GameSession(
            id: UUID(),
            mapId: mapId,
            startTime: Date(),
            discoveredTreasures: Set([UUID()]),
            totalPoints: 100,
            isActive: true
        )
        
        try await mockRepo.saveProgress(session)
        let loadedSession = try await mockRepo.loadProgress(for: mapId)
        
        #expect(loadedSession?.id == session.id)
        #expect(loadedSession?.mapId == mapId)
        #expect(loadedSession?.totalPoints == 100)
        #expect(mockRepo.saveProgressWasCalledCount == 1)
        #expect(mockRepo.loadProgressWasCalledCount == 1)
    }
    
    @Test("MockGameProgressRepository should return nil for non-existent progress")
    func testLoadNonExistentProgress() async throws {
        let mockRepo = MockGameProgressRepository()
        
        let nonExistentMapId = UUID()
        let session = try await mockRepo.loadProgress(for: nonExistentMapId)
        
        #expect(session == nil)
        #expect(mockRepo.loadProgressWasCalledCount == 1)
    }
    
    @Test("MockGameProgressRepository should track discovered treasures")
    func testGetDiscoveredTreasures() async throws {
        let mockRepo = MockGameProgressRepository()
        
        let mapId = UUID()
        let treasureId1 = UUID()
        let treasureId2 = UUID()
        let discoveredTreasures = Set([treasureId1, treasureId2])
        
        let session = GameSession(
            id: UUID(),
            mapId: mapId,
            startTime: Date(),
            discoveredTreasures: discoveredTreasures,
            totalPoints: 200,
            isActive: true
        )
        
        try await mockRepo.saveProgress(session)
        let retrievedTreasures = try await mockRepo.getDiscoveredTreasures(for: mapId)
        
        #expect(retrievedTreasures.count == 2)
        #expect(retrievedTreasures.contains(treasureId1))
        #expect(retrievedTreasures.contains(treasureId2))
        #expect(mockRepo.getDiscoveredTreasuresWasCalledCount == 1)
    }
    
    @Test("MockGameProgressRepository should return empty set for non-existent map")
    func testGetDiscoveredTreasuresForNonExistentMap() async throws {
        let mockRepo = MockGameProgressRepository()
        
        let nonExistentMapId = UUID()
        let treasures = try await mockRepo.getDiscoveredTreasures(for: nonExistentMapId)
        
        #expect(treasures.isEmpty)
    }
    
    @Test("MockGameProgressRepository should save and retrieve total score")
    func testSaveAndGetTotalScore() async throws {
        let mockRepo = MockGameProgressRepository()
        
        try await mockRepo.saveTotalScore(500)
        let score = try await mockRepo.getTotalScore()
        
        #expect(score == 500)
        #expect(mockRepo.saveTotalScoreWasCalledCount == 1)
        #expect(mockRepo.getTotalScoreWasCalledCount == 1)
    }
    
    @Test("MockGameProgressRepository should return zero score by default")
    func testDefaultTotalScore() async throws {
        let mockRepo = MockGameProgressRepository()
        
        let score = try await mockRepo.getTotalScore()
        
        #expect(score == 0)
    }
    
    @Test("MockGameProgressRepository should clear all progress")
    func testClearAllProgress() async throws {
        let mockRepo = MockGameProgressRepository()
        
        // Set up some data
        let mapId = UUID()
        let session = GameSession(
            id: UUID(),
            mapId: mapId,
            startTime: Date(),
            discoveredTreasures: Set([UUID()]),
            totalPoints: 100,
            isActive: true
        )
        
        try await mockRepo.saveProgress(session)
        try await mockRepo.saveTotalScore(500)
        
        // Clear all progress
        try await mockRepo.clearAllProgress()
        
        // Verify everything is cleared
        let loadedSession = try await mockRepo.loadProgress(for: mapId)
        let score = try await mockRepo.getTotalScore()
        
        #expect(loadedSession == nil)
        #expect(score == 0)
        #expect(mockRepo.clearAllProgressWasCalledCount == 1)
    }
    
    @Test("MockGameProgressRepository should check progress existence")
    func testHasProgress() async throws {
        let mockRepo = MockGameProgressRepository()
        
        let mapId = UUID()
        let session = GameSession(
            id: UUID(),
            mapId: mapId,
            startTime: Date(),
            discoveredTreasures: Set(),
            totalPoints: 0,
            isActive: true
        )
        
        // Initially no progress
        let hasProgressBefore = try await mockRepo.hasProgress(for: mapId)
        #expect(hasProgressBefore == false)
        
        // Save progress
        try await mockRepo.saveProgress(session)
        
        // Now should have progress
        let hasProgressAfter = try await mockRepo.hasProgress(for: mapId)
        #expect(hasProgressAfter == true)
        #expect(mockRepo.hasProgressWasCalledCount == 2)
    }
    
    @Test("MockGameProgressRepository should throw configured errors")
    func testErrorThrowing() async throws {
        let mockRepo = MockGameProgressRepository()
        
        mockRepo.setShouldThrowError(.saveFailed)
        
        let session = GameSession(
            id: UUID(),
            mapId: UUID(),
            startTime: Date(),
            discoveredTreasures: Set(),
            totalPoints: 0,
            isActive: true
        )
        
        await #expect(throws: GameProgressRepositoryError.self) {
            try await mockRepo.saveProgress(session)
        }
        
        await #expect(throws: GameProgressRepositoryError.self) {
            try await mockRepo.loadProgress(for: UUID())
        }
        
        await #expect(throws: GameProgressRepositoryError.self) {
            try await mockRepo.getDiscoveredTreasures(for: UUID())
        }
        
        await #expect(throws: GameProgressRepositoryError.self) {
            try await mockRepo.saveTotalScore(100)
        }
        
        await #expect(throws: GameProgressRepositoryError.self) {
            try await mockRepo.getTotalScore()
        }
        
        await #expect(throws: GameProgressRepositoryError.self) {
            try await mockRepo.clearAllProgress()
        }
        
        await #expect(throws: GameProgressRepositoryError.self) {
            try await mockRepo.hasProgress(for: UUID())
        }
    }
    
    @Test("MockGameProgressRepository should reset state correctly")
    func testReset() async throws {
        let mockRepo = MockGameProgressRepository()
        
        // Set up some state
        let session = GameSession(
            id: UUID(),
            mapId: UUID(),
            startTime: Date(),
            discoveredTreasures: Set(),
            totalPoints: 0,
            isActive: true
        )
        
        try await mockRepo.saveProgress(session)
        try await mockRepo.saveTotalScore(100)
        mockRepo.setShouldThrowError(.loadFailed)
        
        // Make some calls to increment counters
        _ = try? await mockRepo.getTotalScore()
        
        // Reset
        mockRepo.reset()
        
        // Verify reset state
        let score = try await mockRepo.getTotalScore()
        #expect(score == 0)
        #expect(mockRepo.getTotalScoreWasCalledCount == 1) // Should be 1 after reset
    }
}