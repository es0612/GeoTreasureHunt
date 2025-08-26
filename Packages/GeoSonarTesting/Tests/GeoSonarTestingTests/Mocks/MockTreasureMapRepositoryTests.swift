import Testing
import Foundation
import CoreLocation
import GeoSonarTesting
import GeoSonarCore

@Suite("MockTreasureMapRepository Tests")
struct MockTreasureMapRepositoryTests {
    
    @Test("MockTreasureMapRepository should return empty maps by default")
    func testEmptyMapsDefault() async throws {
        let mockRepo = MockTreasureMapRepository()
        
        let maps = try await mockRepo.getAllMaps()
        
        #expect(maps.isEmpty)
        #expect(mockRepo.getAllMapsWasCalledCount == 1)
    }
    
    @Test("MockTreasureMapRepository should return configured mock maps")
    func testConfiguredMockMaps() async throws {
        let mockRepo = MockTreasureMapRepository()
        
        // Create test data
        let testMap = TreasureMap(
            id: UUID(),
            name: "Test Map",
            description: "A test treasure map",
            region: MapRegion(
                center: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753),
                span: MapSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ),
            treasures: [],
            difficulty: .easy
        )
        
        mockRepo.setMockMaps([testMap])
        
        let maps = try await mockRepo.getAllMaps()
        
        #expect(maps.count == 1)
        #expect(maps.first?.id == testMap.id)
        #expect(maps.first?.name == "Test Map")
    }
    
    @Test("MockTreasureMapRepository should return specific map by ID")
    func testGetMapById() async throws {
        let mockRepo = MockTreasureMapRepository()
        
        let testId = UUID()
        let testMap = TreasureMap(
            id: testId,
            name: "Specific Map",
            description: "A specific test map",
            region: MapRegion(
                center: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753),
                span: MapSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ),
            treasures: [],
            difficulty: .medium
        )
        
        mockRepo.setMockMaps([testMap])
        
        let foundMap = try await mockRepo.getMap(by: testId)
        let notFoundMap = try await mockRepo.getMap(by: UUID())
        
        #expect(foundMap?.id == testId)
        #expect(notFoundMap == nil)
        #expect(mockRepo.getMapWasCalledCount == 2)
    }
    
    @Test("MockTreasureMapRepository should check map existence")
    func testMapExists() async throws {
        let mockRepo = MockTreasureMapRepository()
        
        let testId = UUID()
        let testMap = TreasureMap(
            id: testId,
            name: "Existing Map",
            description: "A map that exists",
            region: MapRegion(
                center: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753),
                span: MapSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ),
            treasures: [],
            difficulty: .hard
        )
        
        mockRepo.setMockMaps([testMap])
        
        let exists = try await mockRepo.mapExists(id: testId)
        let notExists = try await mockRepo.mapExists(id: UUID())
        
        #expect(exists == true)
        #expect(notExists == false)
        #expect(mockRepo.mapExistsWasCalledCount == 2)
    }
    
    @Test("MockTreasureMapRepository should throw configured errors")
    func testErrorThrowing() async throws {
        let mockRepo = MockTreasureMapRepository()
        
        mockRepo.setShouldThrowError(.dataCorrupted)
        
        await #expect(throws: TreasureMapRepositoryError.self) {
            try await mockRepo.getAllMaps()
        }
        
        await #expect(throws: TreasureMapRepositoryError.self) {
            try await mockRepo.getMap(by: UUID())
        }
        
        await #expect(throws: TreasureMapRepositoryError.self) {
            try await mockRepo.mapExists(id: UUID())
        }
    }
    
    @Test("MockTreasureMapRepository should reset state correctly")
    func testReset() async throws {
        let mockRepo = MockTreasureMapRepository()
        
        // Set up some state
        let testMap = TreasureMap(
            id: UUID(),
            name: "Test Map",
            description: "A test map",
            region: MapRegion(
                center: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753),
                span: MapSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ),
            treasures: [],
            difficulty: .easy
        )
        
        mockRepo.setMockMaps([testMap])
        mockRepo.setShouldThrowError(.fileNotFound)
        
        // Make some calls to increment counters
        _ = try? await mockRepo.getAllMaps()
        
        // Reset
        mockRepo.reset()
        
        // Verify reset state
        let maps = try await mockRepo.getAllMaps()
        #expect(maps.isEmpty)
        #expect(mockRepo.getAllMapsWasCalledCount == 1) // Should be 1 after reset
    }
}