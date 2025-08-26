import Foundation
import CoreLocation

/// Local implementation of TreasureMapRepository that loads data from JSON files
public final class LocalTreasureMapRepository: TreasureMapRepository, @unchecked Sendable {
    
    // MARK: - Private Properties
    
    private var cachedMaps: [TreasureMap]?
    private let jsonFileName = "treasure_maps.json"
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - TreasureMapRepository Implementation
    
    public func getAllMaps() async throws -> [TreasureMap] {
        // Return cached maps if available
        if let cachedMaps = cachedMaps {
            return cachedMaps
        }
        
        // Load maps from JSON
        let maps = try await loadMapsFromJSON()
        cachedMaps = maps
        return maps
    }
    
    public func getMap(by id: UUID) async throws -> TreasureMap? {
        let allMaps = try await getAllMaps()
        return allMaps.first { $0.id == id }
    }
    
    public func mapExists(id: UUID) async throws -> Bool {
        let allMaps = try await getAllMaps()
        return allMaps.contains { $0.id == id }
    }
    
    // MARK: - Private Methods
    
    private func loadMapsFromJSON() async throws -> [TreasureMap] {
        guard let url = Bundle.module.url(forResource: "treasure_maps", withExtension: "json") else {
            throw TreasureMapRepositoryError.fileNotFound
        }
        
        do {
            let data = try Data(contentsOf: url)
            let jsonResponse = try JSONDecoder().decode(TreasureMapJSONResponse.self, from: data)
            
            // Convert JSON response to TreasureMap objects
            let maps = try jsonResponse.maps.map { jsonMap in
                try convertJSONMapToTreasureMap(jsonMap)
            }
            
            // Validate all maps
            for map in maps {
                guard map.isValidRegion() else {
                    throw TreasureMapRepositoryError.dataCorrupted
                }
                
                // Validate all treasures in the map
                for treasure in map.treasures {
                    guard treasure.isValidDiscoveryRadius() && treasure.isValidPoints() else {
                        throw TreasureMapRepositoryError.dataCorrupted
                    }
                }
            }
            
            return maps
            
        } catch _ as DecodingError {
            throw TreasureMapRepositoryError.invalidFormat
        } catch {
            throw TreasureMapRepositoryError.dataCorrupted
        }
    }
    
    private func convertJSONMapToTreasureMap(_ jsonMap: TreasureMapJSON) throws -> TreasureMap {
        // Convert JSON treasures to Treasure objects
        let treasures = try jsonMap.treasures.map { jsonTreasure in
            guard let treasureId = UUID(uuidString: jsonTreasure.id) else {
                throw TreasureMapRepositoryError.invalidFormat
            }
            
            return Treasure(
                id: treasureId,
                coordinate: jsonTreasure.coordinate.clLocationCoordinate2D,
                name: jsonTreasure.name,
                description: jsonTreasure.description,
                points: jsonTreasure.points,
                discoveryRadius: jsonTreasure.discoveryRadius
            )
        }
        
        // Convert difficulty string to enum
        let difficulty: Difficulty
        switch jsonMap.difficulty.lowercased() {
        case "easy":
            difficulty = .easy
        case "medium":
            difficulty = .medium
        case "hard":
            difficulty = .hard
        default:
            difficulty = .easy // Default fallback
        }
        
        // Create MapRegion
        let region = jsonMap.region.mapRegion
        
        guard let mapId = UUID(uuidString: jsonMap.id) else {
            throw TreasureMapRepositoryError.invalidFormat
        }
        
        return TreasureMap(
            id: mapId,
            name: jsonMap.name,
            description: jsonMap.description,
            region: region,
            treasures: treasures,
            difficulty: difficulty
        )
    }
}

// MARK: - JSON Data Structures

private struct TreasureMapJSONResponse: Codable {
    let maps: [TreasureMapJSON]
}

private struct TreasureMapJSON: Codable {
    let id: String
    let name: String
    let description: String
    let region: MapRegionJSON
    let treasures: [TreasureJSON]
    let difficulty: String
}

private struct MapRegionJSON: Codable {
    let center: CoordinateJSON
    let span: MapSpanJSON
}

private struct CoordinateJSON: Codable {
    let latitude: Double
    let longitude: Double
}

private struct MapSpanJSON: Codable {
    let latitudeDelta: Double
    let longitudeDelta: Double
}

private struct TreasureJSON: Codable {
    let id: String
    let coordinate: CoordinateJSON
    let name: String
    let description: String
    let points: Int
    let discoveryRadius: Double
}

// MARK: - Extensions for JSON Conversion

private extension CoordinateJSON {
    var clLocationCoordinate2D: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

private extension MapSpanJSON {
    var mapSpan: MapSpan {
        return MapSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
}

private extension MapRegionJSON {
    var mapRegion: MapRegion {
        return MapRegion(center: center.clLocationCoordinate2D, span: span.mapSpan)
    }
}