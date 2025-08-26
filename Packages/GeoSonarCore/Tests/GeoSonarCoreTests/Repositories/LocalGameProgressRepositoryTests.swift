import Testing
import Foundation
import CoreLocation
import GeoSonarCore

@Suite("LocalGameProgressRepository Tests")
struct LocalGameProgressRepositoryTests {
    
    private func createTestRepository() -> LocalGameProgressRepository {
        let testDefaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        return LocalGameProgressRepository(userDefaults: testDefaults)
    }
    
    @Test("LocalGameProgressRepository should save and load progress")
    func testSaveAndLoadProgress() async throws {
        let repository = createTestRepository()
        
        let mapId = UUID()
        let session = GameSession(
            id: UUID(),
            mapId: mapId,
            startTime: Date(),
            discoveredTreasures: Set([UUID()]),
            totalPoints: 100,
            isActive: true
        )
        
        try await repository.saveProgress(session)
        let loadedSession = try await repository.loadProgress(for: mapId)
        
        #expect(loadedSession != nil)
        #expect(loadedSession?.id == session.id)
        #expect(loadedSession?.mapId == mapId)
        #expect(loadedSession?.totalPoints == 100)
        #expect(loadedSession?.isActive == true)
        #expect(loadedSession?.discoveredTreasures.count == 1)
    }
    
    @Test("LocalGameProgressRepository should return nil for non-existent progress")
    func testLoadNonExistentProgress() async throws {
        let repository = createTestRepository()
        
        let nonExistentMapId = UUID()
        let session = try await repository.loadProgress(for: nonExistentMapId)
        
        #expect(session == nil)
    }
    
    @Test("LocalGameProgressRepository should track discovered treasures")
    func testGetDiscoveredTreasures() async throws {
        let repository = createTestRepository()
        
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
        
        try await repository.saveProgress(session)
        let retrievedTreasures = try await repository.getDiscoveredTreasures(for: mapId)
        
        #expect(retrievedTreasures.count == 2)
        #expect(retrievedTreasures.contains(treasureId1))
        #expect(retrievedTreasures.contains(treasureId2))
    }
    
    @Test("LocalGameProgressRepository should return empty set for non-existent map")
    func testGetDiscoveredTreasuresForNonExistentMap() async throws {
        let repository = createTestRepository()
        
        let nonExistentMapId = UUID()
        let treasures = try await repository.getDiscoveredTreasures(for: nonExistentMapId)
        
        #expect(treasures.isEmpty)
    }
    
    @Test("LocalGameProgressRepository should save and retrieve total score")
    func testSaveAndGetTotalScore() async throws {
        let repository = createTestRepository()
        
        try await repository.saveTotalScore(500)
        let score = try await repository.getTotalScore()
        
        #expect(score == 500)
    }
    
    @Test("LocalGameProgressRepository should return zero score by default")
    func testDefaultTotalScore() async throws {
        let repository = createTestRepository()
        
        let score = try await repository.getTotalScore()
        
        #expect(score == 0)
    }
    
    @Test("LocalGameProgressRepository should accumulate total score")
    func testAccumulateTotalScore() async throws {
        let repository = createTestRepository()
        
        // Save initial score
        try await repository.saveTotalScore(100)
        
        // Save another session with points
        let mapId = UUID()
        let session = GameSession(
            id: UUID(),
            mapId: mapId,
            startTime: Date(),
            discoveredTreasures: Set([UUID()]),
            totalPoints: 150,
            isActive: false
        )
        
        try await repository.saveProgress(session)
        
        // Total score should be updated
        let totalScore = try await repository.getTotalScore()
        #expect(totalScore >= 150) // Should at least include the session points
    }
    
    @Test("LocalGameProgressRepository should clear all progress")
    func testClearAllProgress() async throws {
        let repository = createTestRepository()
        
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
        
        try await repository.saveProgress(session)
        try await repository.saveTotalScore(500)
        
        // Clear all progress
        try await repository.clearAllProgress()
        
        // Verify everything is cleared
        let loadedSession = try await repository.loadProgress(for: mapId)
        let score = try await repository.getTotalScore()
        
        #expect(loadedSession == nil)
        #expect(score == 0)
    }
    
    @Test("LocalGameProgressRepository should check progress existence")
    func testHasProgress() async throws {
        let repository = createTestRepository()
        
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
        let hasProgressBefore = try await repository.hasProgress(for: mapId)
        #expect(hasProgressBefore == false)
        
        // Save progress
        try await repository.saveProgress(session)
        
        // Now should have progress
        let hasProgressAfter = try await repository.hasProgress(for: mapId)
        #expect(hasProgressAfter == true)
    }
    
    @Test("LocalGameProgressRepository should handle multiple sessions")
    func testMultipleSessions() async throws {
        let repository = createTestRepository()
        
        let mapId1 = UUID()
        let mapId2 = UUID()
        
        let session1 = GameSession(
            id: UUID(),
            mapId: mapId1,
            startTime: Date(),
            discoveredTreasures: Set([UUID()]),
            totalPoints: 100,
            isActive: true
        )
        
        let session2 = GameSession(
            id: UUID(),
            mapId: mapId2,
            startTime: Date(),
            discoveredTreasures: Set([UUID(), UUID()]),
            totalPoints: 200,
            isActive: false
        )
        
        try await repository.saveProgress(session1)
        try await repository.saveProgress(session2)
        
        let loadedSession1 = try await repository.loadProgress(for: mapId1)
        let loadedSession2 = try await repository.loadProgress(for: mapId2)
        
        #expect(loadedSession1?.totalPoints == 100)
        #expect(loadedSession2?.totalPoints == 200)
        #expect(loadedSession1?.isActive == true)
        #expect(loadedSession2?.isActive == false)
    }
    
    @Test("LocalGameProgressRepository should persist data across instances")
    func testDataPersistence() async throws {
        let testDefaults = UserDefaults(suiteName: "test-persistence-\(UUID().uuidString)")!
        
        let mapId = UUID()
        let session = GameSession(
            id: UUID(),
            mapId: mapId,
            startTime: Date(),
            discoveredTreasures: Set([UUID()]),
            totalPoints: 100,
            isActive: true
        )
        
        // Save with first instance
        let repository1 = LocalGameProgressRepository(userDefaults: testDefaults)
        try await repository1.saveProgress(session)
        try await repository1.saveTotalScore(500)
        
        // Load with second instance using same UserDefaults
        let repository2 = LocalGameProgressRepository(userDefaults: testDefaults)
        let loadedSession = try await repository2.loadProgress(for: mapId)
        let totalScore = try await repository2.getTotalScore()
        
        #expect(loadedSession?.id == session.id)
        #expect(totalScore == 500)
    }
}