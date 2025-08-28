import Testing
import CoreLocation
import GeoSonarCore
@testable import GeoSonarTesting

@Suite("MockExplorationService Tests")
struct MockExplorationServiceTests {
    
    @Test("Mock should track distance calculation calls")
    func testDistanceCalculationTracking() async throws {
        let mock = MockExplorationService()
        let userLocation = CLLocation(latitude: 35.7148, longitude: 139.7753)
        let treasureCoordinate = CLLocationCoordinate2D(latitude: 35.7158, longitude: 139.7763)
        
        mock.mockDistance = 100.0
        
        let distance = mock.calculateDistance(from: userLocation, to: treasureCoordinate)
        
        #expect(distance == 100.0)
        #expect(mock.calculateDistanceCalls.count == 1)
        #expect(abs(mock.calculateDistanceCalls[0].0.coordinate.latitude - userLocation.coordinate.latitude) < 0.0001)
        #expect(abs(mock.calculateDistanceCalls[0].1.latitude - treasureCoordinate.latitude) < 0.0001)
    }
    
    @Test("Mock should track direction calculation calls")
    func testDirectionCalculationTracking() async throws {
        let mock = MockExplorationService()
        let userLocation = CLLocation(latitude: 35.7148, longitude: 139.7753)
        let treasureCoordinate = CLLocationCoordinate2D(latitude: 35.7158, longitude: 139.7763)
        
        mock.mockDirection = 45.0
        
        let direction = mock.calculateDirection(from: userLocation, to: treasureCoordinate)
        
        #expect(direction == 45.0)
        #expect(mock.calculateDirectionCalls.count == 1)
        #expect(abs(mock.calculateDirectionCalls[0].0.coordinate.latitude - userLocation.coordinate.latitude) < 0.0001)
        #expect(abs(mock.calculateDirectionCalls[0].1.latitude - treasureCoordinate.latitude) < 0.0001)
    }
    
    @Test("Mock should track treasure discovery calls")
    func testTreasureDiscoveryTracking() async throws {
        let mock = MockExplorationService()
        let userLocation = CLLocation(latitude: 35.7148, longitude: 139.7753)
        
        let treasure = Treasure(
            id: UUID(),
            coordinate: CLLocationCoordinate2D(latitude: 35.7149, longitude: 139.7754),
            name: "テスト宝",
            description: "テスト用の宝",
            points: 100,
            discoveryRadius: 20.0
        )
        
        let treasures = [treasure]
        mock.mockDiscoveredTreasure = treasure
        
        let discoveredTreasure = mock.checkTreasureDiscovery(userLocation: userLocation, treasures: treasures)
        
        #expect(discoveredTreasure?.id == treasure.id)
        #expect(mock.checkTreasureDiscoveryCalls.count == 1)
        #expect(mock.checkTreasureDiscoveryCalls[0].1.count == 1)
        #expect(mock.checkTreasureDiscoveryCalls[0].1[0].id == treasure.id)
    }
    
    @Test("Mock should track nearest treasure calls")
    func testNearestTreasureTracking() async throws {
        let mock = MockExplorationService()
        let userLocation = CLLocation(latitude: 35.7148, longitude: 139.7753)
        
        let treasure1 = Treasure(
            id: UUID(),
            coordinate: CLLocationCoordinate2D(latitude: 35.7149, longitude: 139.7754),
            name: "宝1",
            description: "テスト用の宝",
            points: 100,
            discoveryRadius: 20.0
        )
        
        let treasure2 = Treasure(
            id: UUID(),
            coordinate: CLLocationCoordinate2D(latitude: 35.7150, longitude: 139.7755),
            name: "宝2",
            description: "テスト用の宝",
            points: 200,
            discoveryRadius: 20.0
        )
        
        let treasures = [treasure1, treasure2]
        mock.mockNearestTreasure = treasure1
        
        let nearestTreasure = mock.findNearestTreasure(from: userLocation, in: treasures)
        
        #expect(nearestTreasure?.id == treasure1.id)
        #expect(mock.findNearestTreasureCalls.count == 1)
        #expect(mock.findNearestTreasureCalls[0].1.count == 2)
    }
    
    @Test("Mock should reset state properly")
    func testReset() async throws {
        let mock = MockExplorationService()
        let userLocation = CLLocation(latitude: 35.7148, longitude: 139.7753)
        let treasureCoordinate = CLLocationCoordinate2D(latitude: 35.7158, longitude: 139.7763)
        
        // Set up some state
        mock.mockDistance = 100.0
        mock.mockDirection = 45.0
        _ = mock.calculateDistance(from: userLocation, to: treasureCoordinate)
        _ = mock.calculateDirection(from: userLocation, to: treasureCoordinate)
        
        // Verify state is set
        #expect(mock.mockDistance == 100.0)
        #expect(mock.mockDirection == 45.0)
        #expect(mock.calculateDistanceCalls.count == 1)
        #expect(mock.calculateDirectionCalls.count == 1)
        
        // Reset
        mock.reset()
        
        // Verify state is reset
        #expect(mock.mockDistance == 0.0)
        #expect(mock.mockDirection == 0.0)
        #expect(mock.mockDiscoveredTreasure == nil)
        #expect(mock.mockNearestTreasure == nil)
        #expect(mock.calculateDistanceCalls.isEmpty)
        #expect(mock.calculateDirectionCalls.isEmpty)
        #expect(mock.checkTreasureDiscoveryCalls.isEmpty)
        #expect(mock.findNearestTreasureCalls.isEmpty)
    }
    
    @Test("Mock should setup treasure discovery scenario")
    func testSetupTreasureDiscovery() async throws {
        let mock = MockExplorationService()
        
        let treasure = Treasure(
            id: UUID(),
            coordinate: CLLocationCoordinate2D(latitude: 35.7149, longitude: 139.7754),
            name: "テスト宝",
            description: "テスト用の宝",
            points: 100,
            discoveryRadius: 20.0
        )
        
        mock.setupTreasureDiscovery(treasure: treasure, distance: 15.0, direction: 90.0)
        
        #expect(mock.mockDiscoveredTreasure?.id == treasure.id)
        #expect(mock.mockNearestTreasure?.id == treasure.id)
        #expect(mock.mockDistance == 15.0)
        #expect(mock.mockDirection == 90.0)
    }
    
    @Test("Mock should setup no treasure discovery scenario")
    func testSetupNoTreasureDiscovery() async throws {
        let mock = MockExplorationService()
        
        mock.setupNoTreasureDiscovery(distance: 500.0, direction: 180.0)
        
        #expect(mock.mockDiscoveredTreasure == nil)
        #expect(mock.mockDistance == 500.0)
        #expect(mock.mockDirection == 180.0)
    }
}