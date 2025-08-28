import Testing
import CoreLocation
@testable import GeoSonarCore

@Suite("ExplorationService Tests")
struct ExplorationServiceTests {
    
    // MARK: - Distance Calculation Tests
    
    @Test("距離計算の精度テスト", arguments: [
        // (userLat, userLon, treasureLat, treasureLon, expectedDistance)
        (35.7148, 139.7753, 35.7158, 139.7763, 143.0), // ~143m apart
        (35.7148, 139.7753, 35.7148, 139.7753, 0.0),   // Same location
        (35.7148, 139.7753, 35.7248, 139.7753, 1111.0), // ~1111m apart (1 degree lat)
        (0.0, 0.0, 0.0, 1.0, 111320.0) // 1 degree longitude at equator
    ])
    func testDistanceCalculation(
        userLat: Double, userLon: Double,
        treasureLat: Double, treasureLon: Double,
        expectedDistance: Double
    ) async throws {
        let service = ExplorationService()
        let userLocation = CLLocation(latitude: userLat, longitude: userLon)
        let treasureCoordinate = CLLocationCoordinate2D(
            latitude: treasureLat, 
            longitude: treasureLon
        )
        
        let distance = service.calculateDistance(
            from: userLocation, 
            to: treasureCoordinate
        )
        
        // Allow 10% tolerance for distance calculations
        let tolerance = max(expectedDistance * 0.1, 10.0)
        #expect(abs(distance - expectedDistance) < tolerance)
    }
    
    @Test("距離計算 - 無効な座標")
    func testDistanceCalculationWithInvalidCoordinates() async throws {
        let service = ExplorationService()
        let userLocation = CLLocation(latitude: 35.7148, longitude: 139.7753)
        let invalidCoordinate = CLLocationCoordinate2D(latitude: 200.0, longitude: 300.0)
        
        let distance = service.calculateDistance(from: userLocation, to: invalidCoordinate)
        
        // Should handle invalid coordinates gracefully
        #expect(distance >= 0)
    }
    
    // MARK: - Direction Calculation Tests (Dowsing)
    
    @Test("方向計算テスト", arguments: [
        // (userLat, userLon, treasureLat, treasureLon, expectedBearing)
        (35.7148, 139.7753, 35.7158, 139.7763, 45.0),   // Northeast
        (35.7148, 139.7753, 35.7148, 139.7853, 90.0),   // East
        (35.7148, 139.7753, 35.7048, 139.7753, 180.0),  // South
        (35.7148, 139.7753, 35.7148, 139.7653, 270.0)   // West
    ])
    func testDirectionCalculation(
        userLat: Double, userLon: Double,
        treasureLat: Double, treasureLon: Double,
        expectedBearing: Double
    ) async throws {
        let service = ExplorationService()
        let userLocation = CLLocation(latitude: userLat, longitude: userLon)
        let treasureCoordinate = CLLocationCoordinate2D(
            latitude: treasureLat, 
            longitude: treasureLon
        )
        
        let bearing = service.calculateDirection(
            from: userLocation, 
            to: treasureCoordinate
        )
        
        // Allow 15 degree tolerance for bearing calculations
        let tolerance = 15.0
        let bearingDiff = abs(bearing - expectedBearing)
        let normalizedDiff = min(bearingDiff, 360.0 - bearingDiff)
        #expect(normalizedDiff < tolerance)
    }
    
    @Test("方向計算 - 同じ位置")
    func testDirectionCalculationSameLocation() async throws {
        let service = ExplorationService()
        let location = CLLocation(latitude: 35.7148, longitude: 139.7753)
        let coordinate = CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753)
        
        let bearing = service.calculateDirection(from: location, to: coordinate)
        
        // Should return a valid bearing even for same location
        #expect(bearing >= 0.0 && bearing < 360.0)
    }
    
    // MARK: - Treasure Discovery Tests
    
    @Test("宝発見検出 - 範囲内")
    func testTreasureDiscoveryWithinRange() async throws {
        let service = ExplorationService()
        let userLocation = CLLocation(latitude: 35.7148, longitude: 139.7753)
        
        let nearbyTreasure = Treasure(
            id: UUID(),
            coordinate: CLLocationCoordinate2D(latitude: 35.7149, longitude: 139.7754),
            name: "近くの宝",
            description: "テスト用の宝",
            points: 100,
            discoveryRadius: 20.0
        )
        
        let farTreasure = Treasure(
            id: UUID(),
            coordinate: CLLocationCoordinate2D(latitude: 35.7200, longitude: 139.7800),
            name: "遠くの宝",
            description: "テスト用の宝",
            points: 200,
            discoveryRadius: 10.0
        )
        
        let treasures = [nearbyTreasure, farTreasure]
        
        let discoveredTreasure = service.checkTreasureDiscovery(
            userLocation: userLocation,
            treasures: treasures
        )
        
        #expect(discoveredTreasure?.id == nearbyTreasure.id)
    }
    
    @Test("宝発見検出 - 範囲外")
    func testTreasureDiscoveryOutOfRange() async throws {
        let service = ExplorationService()
        let userLocation = CLLocation(latitude: 35.7148, longitude: 139.7753)
        
        let farTreasure = Treasure(
            id: UUID(),
            coordinate: CLLocationCoordinate2D(latitude: 35.7200, longitude: 139.7800),
            name: "遠くの宝",
            description: "テスト用の宝",
            points: 100,
            discoveryRadius: 10.0
        )
        
        let treasures = [farTreasure]
        
        let discoveredTreasure = service.checkTreasureDiscovery(
            userLocation: userLocation,
            treasures: treasures
        )
        
        #expect(discoveredTreasure == nil)
    }
    
    @Test("宝発見検出 - 複数の宝（最も近いものを選択）")
    func testTreasureDiscoveryMultipleTreasures() async throws {
        let service = ExplorationService()
        let userLocation = CLLocation(latitude: 35.7148, longitude: 139.7753)
        
        let closerTreasure = Treasure(
            id: UUID(),
            coordinate: CLLocationCoordinate2D(latitude: 35.7149, longitude: 139.7754),
            name: "より近い宝",
            description: "テスト用の宝",
            points: 100,
            discoveryRadius: 50.0
        )
        
        let fartherTreasure = Treasure(
            id: UUID(),
            coordinate: CLLocationCoordinate2D(latitude: 35.7150, longitude: 139.7755),
            name: "より遠い宝",
            description: "テスト用の宝",
            points: 200,
            discoveryRadius: 50.0
        )
        
        let treasures = [fartherTreasure, closerTreasure] // Order shouldn't matter
        
        let discoveredTreasure = service.checkTreasureDiscovery(
            userLocation: userLocation,
            treasures: treasures
        )
        
        #expect(discoveredTreasure?.id == closerTreasure.id)
    }
    
    @Test("宝発見検出 - 空の宝リスト")
    func testTreasureDiscoveryEmptyList() async throws {
        let service = ExplorationService()
        let userLocation = CLLocation(latitude: 35.7148, longitude: 139.7753)
        let treasures: [Treasure] = []
        
        let discoveredTreasure = service.checkTreasureDiscovery(
            userLocation: userLocation,
            treasures: treasures
        )
        
        #expect(discoveredTreasure == nil)
    }
    
    // MARK: - Nearest Treasure Tests
    
    @Test("最も近い宝の検索")
    func testFindNearestTreasure() async throws {
        let service = ExplorationService()
        let userLocation = CLLocation(latitude: 35.7148, longitude: 139.7753)
        
        let treasure1 = Treasure(
            id: UUID(),
            coordinate: CLLocationCoordinate2D(latitude: 35.7200, longitude: 139.7800),
            name: "宝1",
            description: "テスト用の宝",
            points: 100,
            discoveryRadius: 10.0
        )
        
        let treasure2 = Treasure(
            id: UUID(),
            coordinate: CLLocationCoordinate2D(latitude: 35.7150, longitude: 139.7760),
            name: "宝2",
            description: "テスト用の宝",
            points: 200,
            discoveryRadius: 10.0
        )
        
        let treasures = [treasure1, treasure2]
        
        let nearestTreasure = service.findNearestTreasure(
            from: userLocation,
            in: treasures
        )
        
        #expect(nearestTreasure?.id == treasure2.id)
    }
    
    @Test("最も近い宝の検索 - 空のリスト")
    func testFindNearestTreasureEmptyList() async throws {
        let service = ExplorationService()
        let userLocation = CLLocation(latitude: 35.7148, longitude: 139.7753)
        let treasures: [Treasure] = []
        
        let nearestTreasure = service.findNearestTreasure(
            from: userLocation,
            in: treasures
        )
        
        #expect(nearestTreasure == nil)
    }
}