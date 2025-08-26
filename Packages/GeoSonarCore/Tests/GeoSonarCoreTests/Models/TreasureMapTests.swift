import Testing
import Foundation
import CoreLocation
@testable import GeoSonarCore

@Suite("TreasureMap Model Tests")
struct TreasureMapTests {
    
    @Test("TreasureMap should be Identifiable")
    func testTreasureMapIdentifiable() {
        let treasureMap = TreasureMap(
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
        
        #expect(treasureMap.id != UUID()) // Should have a valid UUID
    }
    
    @Test("TreasureMap should be Codable")
    func testTreasureMapCodable() throws {
        let originalMap = TreasureMap(
            id: UUID(),
            name: "Tokyo Parks",
            description: "Treasure hunt in Tokyo parks",
            region: MapRegion(
                center: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753),
                span: MapSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ),
            treasures: [
                Treasure(
                    id: UUID(),
                    coordinate: CLLocationCoordinate2D(latitude: 35.7158, longitude: 139.7763),
                    name: "Cherry Blossom Treasure",
                    description: "Hidden under the cherry tree",
                    points: 100,
                    discoveryRadius: 10.0
                )
            ],
            difficulty: .medium
        )
        
        // Test encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalMap)
        #expect(data.count > 0)
        
        // Test decoding
        let decoder = JSONDecoder()
        let decodedMap = try decoder.decode(TreasureMap.self, from: data)
        
        #expect(decodedMap.id == originalMap.id)
        #expect(decodedMap.name == originalMap.name)
        #expect(decodedMap.description == originalMap.description)
        #expect(decodedMap.difficulty == originalMap.difficulty)
        #expect(decodedMap.treasures.count == originalMap.treasures.count)
    }
    
    @Test("TreasureMap should validate region bounds")
    func testTreasureMapRegionValidation() {
        let validRegion = MapRegion(
            center: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753),
            span: MapSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        
        let treasureMap = TreasureMap(
            id: UUID(),
            name: "Valid Map",
            description: "A map with valid coordinates",
            region: validRegion,
            treasures: [],
            difficulty: .easy
        )
        
        #expect(treasureMap.isValidRegion())
    }
    
    @Test("TreasureMap should handle invalid coordinates")
    func testTreasureMapInvalidCoordinates() {
        let invalidRegion = MapRegion(
            center: CLLocationCoordinate2D(latitude: 200.0, longitude: 300.0), // Invalid coordinates
            span: MapSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        
        let treasureMap = TreasureMap(
            id: UUID(),
            name: "Invalid Map",
            description: "A map with invalid coordinates",
            region: invalidRegion,
            treasures: [],
            difficulty: .easy
        )
        
        #expect(!treasureMap.isValidRegion())
    }
    
    @Test("TreasureMap should calculate total points correctly")
    func testTreasureMapTotalPoints() {
        let treasures = [
            Treasure(
                id: UUID(),
                coordinate: CLLocationCoordinate2D(latitude: 35.7158, longitude: 139.7763),
                name: "Treasure 1",
                description: "First treasure",
                points: 100,
                discoveryRadius: 10.0
            ),
            Treasure(
                id: UUID(),
                coordinate: CLLocationCoordinate2D(latitude: 35.7168, longitude: 139.7773),
                name: "Treasure 2",
                description: "Second treasure",
                points: 150,
                discoveryRadius: 15.0
            )
        ]
        
        let treasureMap = TreasureMap(
            id: UUID(),
            name: "Multi Treasure Map",
            description: "A map with multiple treasures",
            region: MapRegion(
                center: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753),
                span: MapSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ),
            treasures: treasures,
            difficulty: .hard
        )
        
        #expect(treasureMap.totalPoints == 250)
    }
}