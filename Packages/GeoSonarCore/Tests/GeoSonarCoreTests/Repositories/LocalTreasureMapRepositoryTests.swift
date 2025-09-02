import Testing
import Foundation
import CoreLocation
import GeoSonarCore

@Suite("LocalTreasureMapRepository Tests")
struct LocalTreasureMapRepositoryTests {
    
    @Test("LocalTreasureMapRepository should load maps from JSON data")
    func testLoadMapsFromJSON() async throws {
        let repository = LocalTreasureMapRepository()
        
        let maps = try await repository.getAllMaps()
        
        #expect(!maps.isEmpty)
        #expect(maps.count >= 1)
        
        // Verify the first map has expected structure
        let firstMap = maps.first!
        #expect(!firstMap.name.isEmpty)
        #expect(!firstMap.description.isEmpty)
        #expect(!firstMap.treasures.isEmpty)
        #expect(firstMap.isValidRegion())
    }
    
    @Test("LocalTreasureMapRepository should return specific map by ID")
    func testGetMapById() async throws {
        let repository = LocalTreasureMapRepository()
        
        let allMaps = try await repository.getAllMaps()
        let firstMap = allMaps.first!
        
        let foundMap = try await repository.getMap(by: firstMap.id)
        
        #expect(foundMap != nil)
        #expect(foundMap?.id == firstMap.id)
        #expect(foundMap?.name == firstMap.name)
    }
    
    @Test("LocalTreasureMapRepository should return nil for non-existent map ID")
    func testGetNonExistentMapById() async throws {
        let repository = LocalTreasureMapRepository()
        
        let nonExistentId = UUID()
        let foundMap = try await repository.getMap(by: nonExistentId)
        
        #expect(foundMap == nil)
    }
    
    @Test("LocalTreasureMapRepository should check map existence correctly")
    func testMapExists() async throws {
        let repository = LocalTreasureMapRepository()
        
        let allMaps = try await repository.getAllMaps()
        let existingId = allMaps.first!.id
        let nonExistentId = UUID()
        
        let exists = try await repository.mapExists(id: existingId)
        let notExists = try await repository.mapExists(id: nonExistentId)
        
        #expect(exists == true)
        #expect(notExists == false)
    }
    
    @Test("LocalTreasureMapRepository should load Tokyo park area sample data")
    func testTokyoParkAreaData() async throws {
        let repository = LocalTreasureMapRepository()
        
        let maps = try await repository.getAllMaps()
        
        // Should have at least one Tokyo park area map
        let tokyoMap = maps.first { $0.name.contains("東京") || $0.name.contains("公園") }
        #expect(tokyoMap != nil)
        
        if let tokyoMap = tokyoMap {
            // Verify it's in Tokyo area (roughly)
            let center = tokyoMap.region.center
            #expect(center.latitude > 35.0 && center.latitude < 36.0)
            #expect(center.longitude > 139.0 && center.longitude < 140.0)
            
            // Should have treasures
            #expect(!tokyoMap.treasures.isEmpty)
            
            // Treasures should have valid discovery radius
            for treasure in tokyoMap.treasures {
                #expect(treasure.isValidDiscoveryRadius())
                #expect(treasure.points > 0)
            }
        }
    }
    
    @Test("LocalTreasureMapRepository should handle corrupted data gracefully")
    func testCorruptedDataHandling() async throws {
        // This test will be implemented when we add error handling for corrupted data
        // For now, we'll test that the repository doesn't crash with valid data
        let repository = LocalTreasureMapRepository()
        
        // Should not throw for valid data
        let maps = try await repository.getAllMaps()
        // Should at least not crash - maps can be empty or contain items
        _ = maps // Just verify we can get maps without crashing
    }
    
    @Test("LocalTreasureMapRepository should validate treasure coordinates")
    func testTreasureCoordinateValidation() async throws {
        let repository = LocalTreasureMapRepository()
        
        let maps = try await repository.getAllMaps()
        
        for map in maps {
            for treasure in map.treasures {
                // Validate coordinates are within valid ranges
                #expect(treasure.coordinate.latitude >= -90.0 && treasure.coordinate.latitude <= 90.0)
                #expect(treasure.coordinate.longitude >= -180.0 && treasure.coordinate.longitude <= 180.0)
                
                // Validate treasure is within reasonable distance of map center
                let mapCenter = map.region.center
                let distance = treasure.distanceFrom(
                    location: CLLocation(latitude: mapCenter.latitude, longitude: mapCenter.longitude)
                )
                
                // Should be within 10km of map center (reasonable for a local treasure hunt)
                #expect(distance < 10000.0)
            }
        }
    }
}