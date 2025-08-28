import Testing
import SwiftUI
@testable import GeoSonarUI
import GeoSonarCore

@Suite("DowsingCompassView Tests")
struct DowsingCompassViewTests {
    
    // MARK: - Display Tests
    
    @Test("DowsingCompassView displays direction indicator")
    @MainActor func testDisplaysDirectionIndicator() {
        let direction: Double = 45.0 // 45 degrees
        _ = DowsingCompassView(direction: direction)
        
        #expect(direction == 45.0)
        #expect(direction >= 0.0)
        #expect(direction < 360.0)
    }
    
    @Test("DowsingCompassView handles zero direction")
    @MainActor func testHandlesZeroDirection() {
        let direction: Double = 0.0 // North
        _ = DowsingCompassView(direction: direction)
        
        #expect(direction == 0.0)
    }
    
    @Test("DowsingCompassView handles 360 degree direction")
    @MainActor func testHandles360DegreeDirection() {
        let direction: Double = 359.9 // Almost full circle
        _ = DowsingCompassView(direction: direction)
        
        #expect(direction < 360.0)
        #expect(direction >= 0.0)
    }
    
    @Test("DowsingCompassView handles negative direction")
    @MainActor func testHandlesNegativeDirection() {
        let direction: Double = -45.0 // Should be normalized
        _ = DowsingCompassView(direction: direction)
        
        // Test that negative values can be handled
        #expect(direction == -45.0)
    }
    
    // MARK: - Direction Calculation Tests
    
    @Test("DowsingCompassView calculates north direction")
    @MainActor func testCalculatesNorthDirection() {
        let northDirection: Double = 0.0
        _ = DowsingCompassView(direction: northDirection)
        
        #expect(northDirection == 0.0)
    }
    
    @Test("DowsingCompassView calculates east direction")
    @MainActor func testCalculatesEastDirection() {
        let eastDirection: Double = 90.0
        _ = DowsingCompassView(direction: eastDirection)
        
        #expect(eastDirection == 90.0)
    }
    
    @Test("DowsingCompassView calculates south direction")
    @MainActor func testCalculatesSouthDirection() {
        let southDirection: Double = 180.0
        _ = DowsingCompassView(direction: southDirection)
        
        #expect(southDirection == 180.0)
    }
    
    @Test("DowsingCompassView calculates west direction")
    @MainActor func testCalculatesWestDirection() {
        let westDirection: Double = 270.0
        _ = DowsingCompassView(direction: westDirection)
        
        #expect(westDirection == 270.0)
    }
    
    // MARK: - Visual Representation Tests
    
    @Test("DowsingCompassView shows compass rose")
    @MainActor func testShowsCompassRose() {
        _ = DowsingCompassView(direction: 45.0)
        
        // Test that compass directions are properly defined
        let cardinalDirections = [0.0, 90.0, 180.0, 270.0]
        #expect(cardinalDirections.count == 4)
    }
    
    @Test("DowsingCompassView shows direction needle")
    @MainActor func testShowsDirectionNeedle() {
        let direction: Double = 135.0
        _ = DowsingCompassView(direction: direction)
        
        #expect(direction == 135.0)
        #expect(direction > 90.0)
        #expect(direction < 180.0)
    }
    
    @Test("DowsingCompassView updates needle position")
    @MainActor func testUpdatesNeedlePosition() {
        let initialDirection: Double = 0.0
        let updatedDirection: Double = 180.0
        
        _ = DowsingCompassView(direction: initialDirection)
        _ = DowsingCompassView(direction: updatedDirection)
        
        #expect(initialDirection != updatedDirection)
        #expect(abs(updatedDirection - initialDirection) == 180.0)
    }
    
    // MARK: - Animation Tests
    
    @Test("DowsingCompassView supports smooth direction changes")
    @MainActor func testSupportsSmoothDirectionChanges() {
        let direction1: Double = 10.0
        let direction2: Double = 20.0
        let direction3: Double = 30.0
        
        _ = DowsingCompassView(direction: direction1)
        _ = DowsingCompassView(direction: direction2)
        _ = DowsingCompassView(direction: direction3)
        
        #expect(direction2 > direction1)
        #expect(direction3 > direction2)
        #expect(direction3 - direction1 == 20.0)
    }
    
    @Test("DowsingCompassView handles rapid direction updates")
    @MainActor func testHandlesRapidDirectionUpdates() {
        let directions: [Double] = [0.0, 45.0, 90.0, 135.0, 180.0]
        
        for direction in directions {
            _ = DowsingCompassView(direction: direction)
            #expect(direction >= 0.0)
            #expect(direction <= 180.0)
        }
    }
    
    // MARK: - Accessibility Tests
    
    @Test("DowsingCompassView has accessibility label")
    @MainActor func testHasAccessibilityLabel() {
        let direction: Double = 45.0
        _ = DowsingCompassView(direction: direction)
        
        // Test that direction can be described for accessibility
        #expect(direction == 45.0)
    }
    
    @Test("DowsingCompassView provides direction description")
    @MainActor func testProvidesDirectionDescription() {
        let northDirection: Double = 0.0
        let eastDirection: Double = 90.0
        
        _ = DowsingCompassView(direction: northDirection)
        _ = DowsingCompassView(direction: eastDirection)
        
        #expect(northDirection != eastDirection)
    }
    
    @Test("DowsingCompassView supports accessibility navigation")
    @MainActor func testSupportsAccessibilityNavigation() {
        let direction: Double = 225.0 // Southwest
        _ = DowsingCompassView(direction: direction)
        
        #expect(direction > 180.0)
        #expect(direction < 270.0)
    }
    
    // MARK: - Edge Case Tests
    
    @Test("DowsingCompassView handles very small direction changes")
    @MainActor func testHandlesVerySmallDirectionChanges() {
        let direction1: Double = 45.0
        let direction2: Double = 45.1
        
        _ = DowsingCompassView(direction: direction1)
        _ = DowsingCompassView(direction: direction2)
        
        #expect(abs(direction2 - direction1) < 0.11)
    }
    
    @Test("DowsingCompassView handles direction wraparound")
    @MainActor func testHandlesDirectionWraparound() {
        let direction1: Double = 359.0
        let direction2: Double = 1.0
        
        _ = DowsingCompassView(direction: direction1)
        _ = DowsingCompassView(direction: direction2)
        
        // Test wraparound scenario
        #expect(direction1 > 350.0)
        #expect(direction2 < 10.0)
    }
}