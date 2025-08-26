import Testing
import Foundation
import CoreLocation
@testable import GeoSonarCore

@Suite("GameSession Model Tests")
struct GameSessionTests {
    
    @Test("GameSession should be Identifiable")
    func testGameSessionIdentifiable() {
        let session = GameSession(
            id: UUID(),
            mapId: UUID(),
            startTime: Date(),
            discoveredTreasures: Set<UUID>(),
            totalPoints: 0,
            isActive: true
        )
        
        #expect(session.id != UUID()) // Should have a valid UUID
    }
    
    @Test("GameSession should be Codable")
    func testGameSessionCodable() throws {
        let treasureId1 = UUID()
        let treasureId2 = UUID()
        let originalSession = GameSession(
            id: UUID(),
            mapId: UUID(),
            startTime: Date(),
            discoveredTreasures: Set([treasureId1, treasureId2]),
            totalPoints: 250,
            isActive: false
        )
        
        // Test encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalSession)
        #expect(data.count > 0)
        
        // Test decoding
        let decoder = JSONDecoder()
        let decodedSession = try decoder.decode(GameSession.self, from: data)
        
        #expect(decodedSession.id == originalSession.id)
        #expect(decodedSession.mapId == originalSession.mapId)
        #expect(decodedSession.totalPoints == originalSession.totalPoints)
        #expect(decodedSession.isActive == originalSession.isActive)
        #expect(decodedSession.discoveredTreasures == originalSession.discoveredTreasures)
    }
    
    @Test("GameSession should track discovered treasures")
    func testGameSessionTreasureTracking() {
        var session = GameSession(
            id: UUID(),
            mapId: UUID(),
            startTime: Date(),
            discoveredTreasures: Set<UUID>(),
            totalPoints: 0,
            isActive: true
        )
        
        let treasureId = UUID()
        
        // Initially no treasures discovered
        #expect(session.discoveredTreasures.isEmpty)
        #expect(!session.hasTreasureBeenDiscovered(treasureId))
        
        // Discover a treasure
        session.discoverTreasure(treasureId, points: 100)
        
        #expect(session.discoveredTreasures.contains(treasureId))
        #expect(session.hasTreasureBeenDiscovered(treasureId))
        #expect(session.totalPoints == 100)
    }
    
    @Test("GameSession should prevent duplicate treasure discoveries")
    func testGameSessionDuplicateDiscoveryPrevention() {
        var session = GameSession(
            id: UUID(),
            mapId: UUID(),
            startTime: Date(),
            discoveredTreasures: Set<UUID>(),
            totalPoints: 0,
            isActive: true
        )
        
        let treasureId = UUID()
        
        // Discover treasure first time
        let firstDiscovery = session.discoverTreasure(treasureId, points: 100)
        #expect(firstDiscovery == true)
        #expect(session.totalPoints == 100)
        
        // Try to discover same treasure again
        let secondDiscovery = session.discoverTreasure(treasureId, points: 100)
        #expect(secondDiscovery == false)
        #expect(session.totalPoints == 100) // Points should not increase
    }
    
    @Test("GameSession should calculate completion percentage")
    func testGameSessionCompletionPercentage() {
        let treasureId1 = UUID()
        let treasureId2 = UUID()
        let treasureId3 = UUID()
        
        var session = GameSession(
            id: UUID(),
            mapId: UUID(),
            startTime: Date(),
            discoveredTreasures: Set<UUID>(),
            totalPoints: 0,
            isActive: true
        )
        
        let totalTreasures = [treasureId1, treasureId2, treasureId3]
        
        // No treasures discovered
        #expect(session.completionPercentage(totalTreasures: totalTreasures) == 0.0)
        
        // One treasure discovered
        session.discoverTreasure(treasureId1, points: 100)
        #expect(abs(session.completionPercentage(totalTreasures: totalTreasures) - 33.33) < 0.1)
        
        // Two treasures discovered
        session.discoverTreasure(treasureId2, points: 150)
        #expect(abs(session.completionPercentage(totalTreasures: totalTreasures) - 66.67) < 0.1)
        
        // All treasures discovered
        session.discoverTreasure(treasureId3, points: 200)
        #expect(session.completionPercentage(totalTreasures: totalTreasures) == 100.0)
    }
    
    @Test("GameSession should calculate session duration")
    func testGameSessionDuration() {
        let startTime = Date()
        let session = GameSession(
            id: UUID(),
            mapId: UUID(),
            startTime: startTime,
            discoveredTreasures: Set<UUID>(),
            totalPoints: 0,
            isActive: true
        )
        
        // Test duration calculation
        let duration = session.sessionDuration()
        #expect(duration >= 0)
        #expect(duration < 1.0) // Should be less than 1 second for this test
    }
    
    @Test("GameSession should validate session state")
    func testGameSessionValidation() {
        let validSession = GameSession(
            id: UUID(),
            mapId: UUID(),
            startTime: Date(),
            discoveredTreasures: Set<UUID>(),
            totalPoints: 0,
            isActive: true
        )
        
        #expect(validSession.isValidSession())
        
        let invalidSession = GameSession(
            id: UUID(),
            mapId: UUID(),
            startTime: Date().addingTimeInterval(3600), // Future start time
            discoveredTreasures: Set<UUID>(),
            totalPoints: -100, // Negative points
            isActive: true
        )
        
        #expect(!invalidSession.isValidSession())
    }
    
    @Test("GameSession should end session properly")
    func testGameSessionEnd() {
        var session = GameSession(
            id: UUID(),
            mapId: UUID(),
            startTime: Date(),
            discoveredTreasures: Set<UUID>(),
            totalPoints: 100,
            isActive: true
        )
        
        #expect(session.isActive)
        
        session.endSession()
        
        #expect(!session.isActive)
    }
}