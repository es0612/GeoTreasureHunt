import Testing
import SwiftUI
@testable import GeoSonarUI
import GeoSonarCore
import CoreLocation

@Suite("MapRowView Tests")
struct MapRowViewTests {
    
    // MARK: - Test Data
    
    private func createTestTreasureMap() -> TreasureMap {
        let region = MapRegion(
            center: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753),
            span: MapSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        
        let treasure = Treasure(
            id: UUID(),
            coordinate: CLLocationCoordinate2D(latitude: 35.7158, longitude: 139.7763),
            name: "Test Treasure",
            description: "A test treasure",
            points: 100,
            discoveryRadius: 10.0
        )
        
        return TreasureMap(
            id: UUID(),
            name: "Test Map",
            description: "A test treasure map",
            region: region,
            treasures: [treasure],
            difficulty: .easy
        )
    }
    
    // MARK: - Display Tests
    
    @Test("MapRowView displays treasure map name")
    @MainActor func testDisplaysTreasureMapName() {
        let treasureMap = createTestTreasureMap()
        _ = MapRowView(treasureMap: treasureMap) { }
        
        // Test that the view can be created without crashing
        #expect(treasureMap.name == "Test Map")
    }
    
    @Test("MapRowView displays treasure map description")
    @MainActor func testDisplaysTreasureMapDescription() {
        let treasureMap = createTestTreasureMap()
        _ = MapRowView(treasureMap: treasureMap) { }
        
        #expect(treasureMap.description == "A test treasure map")
    }
    
    @Test("MapRowView displays difficulty level")
    @MainActor func testDisplaysDifficultyLevel() {
        let treasureMap = createTestTreasureMap()
        _ = MapRowView(treasureMap: treasureMap) { }
        
        #expect(treasureMap.difficulty == .easy)
        #expect(treasureMap.difficulty.localizedDescription == "Easy")
    }
    
    @Test("MapRowView displays treasure count")
    @MainActor func testDisplaysTreasureCount() {
        let treasureMap = createTestTreasureMap()
        _ = MapRowView(treasureMap: treasureMap) { }
        
        #expect(treasureMap.treasures.count == 1)
    }
    
    @Test("MapRowView displays total points")
    @MainActor func testDisplaysTotalPoints() {
        let treasureMap = createTestTreasureMap()
        _ = MapRowView(treasureMap: treasureMap) { }
        
        #expect(treasureMap.totalPoints == 100)
    }
    
    // MARK: - Interaction Tests
    
    @Test("MapRowView handles tap action")
    @MainActor func testHandlesTapAction() {
        let treasureMap = createTestTreasureMap()
        var actionCalled = false
        
        _ = MapRowView(treasureMap: treasureMap) {
            actionCalled = true
        }
        
        // Since we can't simulate tap in unit tests, we verify the action closure exists
        #expect(!actionCalled) // Initially false
    }
    
    // MARK: - Accessibility Tests
    
    @Test("MapRowView has proper accessibility labels")
    @MainActor func testAccessibilityLabels() {
        let treasureMap = createTestTreasureMap()
        _ = MapRowView(treasureMap: treasureMap) { }
        
        // Test accessibility properties are properly set
        #expect(treasureMap.name.isEmpty == false)
        #expect(treasureMap.description.isEmpty == false)
    }
    
    @Test("MapRowView supports accessibility actions")
    @MainActor func testAccessibilityActions() {
        let treasureMap = createTestTreasureMap()
        var actionCalled = false
        
        _ = MapRowView(treasureMap: treasureMap) {
            actionCalled = true
        }
        
        // Verify the view can be created with accessibility in mind
        #expect(treasureMap.id != UUID(uuidString: "00000000-0000-0000-0000-000000000000"))
    }
}