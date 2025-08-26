import Testing
import Foundation
import CoreLocation
@testable import GeoSonarCore

@Suite("Treasure Model Tests")
struct TreasureTests {
    
    @Test("Treasure should be Identifiable")
    func testTreasureIdentifiable() {
        let treasure = Treasure(
            id: UUID(),
            coordinate: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753),
            name: "Test Treasure",
            description: "A test treasure",
            points: 100,
            discoveryRadius: 10.0
        )
        
        #expect(treasure.id != UUID()) // Should have a valid UUID
    }
    
    @Test("Treasure should be Codable")
    func testTreasureCodable() throws {
        let originalTreasure = Treasure(
            id: UUID(),
            coordinate: CLLocationCoordinate2D(latitude: 35.7158, longitude: 139.7763),
            name: "Cherry Blossom Treasure",
            description: "Hidden under the cherry tree",
            points: 100,
            discoveryRadius: 10.0
        )
        
        // Test encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalTreasure)
        #expect(data.count > 0)
        
        // Test decoding
        let decoder = JSONDecoder()
        let decodedTreasure = try decoder.decode(Treasure.self, from: data)
        
        #expect(decodedTreasure.id == originalTreasure.id)
        #expect(decodedTreasure.name == originalTreasure.name)
        #expect(decodedTreasure.description == originalTreasure.description)
        #expect(decodedTreasure.points == originalTreasure.points)
        #expect(decodedTreasure.discoveryRadius == originalTreasure.discoveryRadius)
        #expect(abs(decodedTreasure.coordinate.latitude - originalTreasure.coordinate.latitude) < 0.0001)
        #expect(abs(decodedTreasure.coordinate.longitude - originalTreasure.coordinate.longitude) < 0.0001)
    }
    
    @Test("Treasure should validate discovery radius", arguments: [
        (5.0, true),   // Valid minimum radius
        (100.0, true), // Valid maximum radius
        (0.0, false),  // Invalid: zero radius
        (-5.0, false), // Invalid: negative radius
        (1000.0, false) // Invalid: too large radius
    ])
    func testTreasureDiscoveryRadiusValidation(radius: Double, expectedValid: Bool) {
        let treasure = Treasure(
            id: UUID(),
            coordinate: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753),
            name: "Test Treasure",
            description: "A test treasure",
            points: 100,
            discoveryRadius: radius
        )
        
        #expect(treasure.isValidDiscoveryRadius() == expectedValid)
    }
    
    @Test("Treasure should validate coordinate bounds")
    func testTreasureCoordinateValidation() {
        let validTreasure = Treasure(
            id: UUID(),
            coordinate: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753),
            name: "Valid Treasure",
            description: "A treasure with valid coordinates",
            points: 100,
            discoveryRadius: 10.0
        )
        
        #expect(validTreasure.isValidCoordinate())
        
        let invalidTreasure = Treasure(
            id: UUID(),
            coordinate: CLLocationCoordinate2D(latitude: 200.0, longitude: 300.0), // Invalid coordinates
            name: "Invalid Treasure",
            description: "A treasure with invalid coordinates",
            points: 100,
            discoveryRadius: 10.0
        )
        
        #expect(!invalidTreasure.isValidCoordinate())
    }
    
    @Test("Treasure should validate points", arguments: [
        (1, true),     // Valid minimum points
        (100, true),   // Valid points
        (1000, true),  // Valid high points
        (0, false),    // Invalid: zero points
        (-10, false)   // Invalid: negative points
    ])
    func testTreasurePointsValidation(points: Int, expectedValid: Bool) {
        let treasure = Treasure(
            id: UUID(),
            coordinate: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753),
            name: "Test Treasure",
            description: "A test treasure",
            points: points,
            discoveryRadius: 10.0
        )
        
        #expect(treasure.isValidPoints() == expectedValid)
    }
    
    @Test("Treasure should calculate distance from location")
    func testTreasureDistanceCalculation() {
        let treasure = Treasure(
            id: UUID(),
            coordinate: CLLocationCoordinate2D(latitude: 35.7158, longitude: 139.7763),
            name: "Distance Test Treasure",
            description: "For testing distance calculation",
            points: 100,
            discoveryRadius: 10.0
        )
        
        let userLocation = CLLocation(latitude: 35.7148, longitude: 139.7753)
        let distance = treasure.distanceFrom(location: userLocation)
        
        // Distance should be approximately 111 meters (rough calculation for this coordinate difference)
        #expect(distance > 100.0)
        #expect(distance < 150.0)
    }
    
    @Test("Treasure should detect if user is within discovery radius")
    func testTreasureDiscoveryDetection() {
        let treasure = Treasure(
            id: UUID(),
            coordinate: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753),
            name: "Discovery Test Treasure",
            description: "For testing discovery detection",
            points: 100,
            discoveryRadius: 50.0
        )
        
        // User very close to treasure (should be discoverable)
        let closeLocation = CLLocation(latitude: 35.7148, longitude: 139.7753)
        #expect(treasure.isDiscoverableFrom(location: closeLocation))
        
        // User far from treasure (should not be discoverable)
        let farLocation = CLLocation(latitude: 35.8000, longitude: 139.8000)
        #expect(!treasure.isDiscoverableFrom(location: farLocation))
    }
}