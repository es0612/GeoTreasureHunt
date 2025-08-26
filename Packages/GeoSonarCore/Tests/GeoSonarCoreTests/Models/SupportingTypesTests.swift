import Testing
import Foundation
import CoreLocation
@testable import GeoSonarCore

@Suite("Supporting Types Tests")
struct SupportingTypesTests {
    
    @Test("MapRegion should be Codable")
    func testMapRegionCodable() throws {
        let originalRegion = MapRegion(
            center: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753),
            span: MapSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        
        // Test encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalRegion)
        #expect(data.count > 0)
        
        // Test decoding
        let decoder = JSONDecoder()
        let decodedRegion = try decoder.decode(MapRegion.self, from: data)
        
        #expect(abs(decodedRegion.center.latitude - originalRegion.center.latitude) < 0.0001)
        #expect(abs(decodedRegion.center.longitude - originalRegion.center.longitude) < 0.0001)
        #expect(abs(decodedRegion.span.latitudeDelta - originalRegion.span.latitudeDelta) < 0.0001)
        #expect(abs(decodedRegion.span.longitudeDelta - originalRegion.span.longitudeDelta) < 0.0001)
    }
    
    @Test("MapSpan should be Codable")
    func testMapSpanCodable() throws {
        let originalSpan = MapSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        
        // Test encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalSpan)
        #expect(data.count > 0)
        
        // Test decoding
        let decoder = JSONDecoder()
        let decodedSpan = try decoder.decode(MapSpan.self, from: data)
        
        #expect(abs(decodedSpan.latitudeDelta - originalSpan.latitudeDelta) < 0.0001)
        #expect(abs(decodedSpan.longitudeDelta - originalSpan.longitudeDelta) < 0.0001)
    }
    
    @Test("Difficulty enum should be Codable", arguments: [
        Difficulty.easy,
        Difficulty.medium,
        Difficulty.hard
    ])
    func testDifficultyCodable(difficulty: Difficulty) throws {
        // Test encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(difficulty)
        #expect(data.count > 0)
        
        // Test decoding
        let decoder = JSONDecoder()
        let decodedDifficulty = try decoder.decode(Difficulty.self, from: data)
        
        #expect(decodedDifficulty == difficulty)
    }
    
    @Test("Difficulty enum should have correct raw values")
    func testDifficultyRawValues() {
        #expect(Difficulty.easy.rawValue == "easy")
        #expect(Difficulty.medium.rawValue == "medium")
        #expect(Difficulty.hard.rawValue == "hard")
    }
    
    @Test("Difficulty enum should provide localized descriptions")
    func testDifficultyLocalizedDescriptions() {
        #expect(!Difficulty.easy.localizedDescription.isEmpty)
        #expect(!Difficulty.medium.localizedDescription.isEmpty)
        #expect(!Difficulty.hard.localizedDescription.isEmpty)
        
        // Test that descriptions are different
        #expect(Difficulty.easy.localizedDescription != Difficulty.medium.localizedDescription)
        #expect(Difficulty.medium.localizedDescription != Difficulty.hard.localizedDescription)
    }
    
    @Test("ExplorationMode enum should be CaseIterable")
    func testExplorationModeCaseIterable() {
        let allModes = ExplorationMode.allCases
        #expect(allModes.count == 2)
        #expect(allModes.contains(.dowsing))
        #expect(allModes.contains(.sonar))
    }
    
    @Test("ExplorationMode enum should provide localized descriptions")
    func testExplorationModeLocalizedDescriptions() {
        #expect(!ExplorationMode.dowsing.localizedDescription.isEmpty)
        #expect(!ExplorationMode.sonar.localizedDescription.isEmpty)
        
        // Test that descriptions are different
        #expect(ExplorationMode.dowsing.localizedDescription != ExplorationMode.sonar.localizedDescription)
    }
    
    @Test("CLLocationCoordinate2D should be Codable through custom implementation")
    func testCLLocationCoordinate2DCodable() throws {
        let originalCoordinate = CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753)
        
        // Test encoding through our custom Codable implementation
        let encoder = JSONEncoder()
        let data = try encoder.encode(CodableCoordinate(coordinate: originalCoordinate))
        #expect(data.count > 0)
        
        // Test decoding
        let decoder = JSONDecoder()
        let decodedCodableCoordinate = try decoder.decode(CodableCoordinate.self, from: data)
        let decodedCoordinate = decodedCodableCoordinate.coordinate
        
        #expect(abs(decodedCoordinate.latitude - originalCoordinate.latitude) < 0.0001)
        #expect(abs(decodedCoordinate.longitude - originalCoordinate.longitude) < 0.0001)
    }
}