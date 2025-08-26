import Foundation
import CoreLocation

// MARK: - Map Region and Span

/// Represents a geographical region with center and span
public struct MapRegion: Codable, Equatable, Sendable {
    public let center: CLLocationCoordinate2D
    public let span: MapSpan
    
    public init(center: CLLocationCoordinate2D, span: MapSpan) {
        self.center = center
        self.span = span
    }
    
    // MARK: - Equatable Conformance
    
    public static func == (lhs: MapRegion, rhs: MapRegion) -> Bool {
        return abs(lhs.center.latitude - rhs.center.latitude) < 0.0001 &&
               abs(lhs.center.longitude - rhs.center.longitude) < 0.0001 &&
               lhs.span == rhs.span
    }
    
    // Custom Codable implementation for CLLocationCoordinate2D
    private enum CodingKeys: String, CodingKey {
        case center, span
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let centerData = try container.decode(CodableCoordinate.self, forKey: .center)
        self.center = centerData.coordinate
        self.span = try container.decode(MapSpan.self, forKey: .span)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(CodableCoordinate(coordinate: center), forKey: .center)
        try container.encode(span, forKey: .span)
    }
}

/// Represents the span (zoom level) of a map region
public struct MapSpan: Codable, Equatable, Sendable {
    public let latitudeDelta: Double
    public let longitudeDelta: Double
    
    public init(latitudeDelta: Double, longitudeDelta: Double) {
        self.latitudeDelta = latitudeDelta
        self.longitudeDelta = longitudeDelta
    }
}

// MARK: - Difficulty Enum

/// Represents the difficulty level of a treasure map
public enum Difficulty: String, Codable, CaseIterable, Sendable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    
    /// Localized description for the difficulty level
    public var localizedDescription: String {
        switch self {
        case .easy:
            return "Easy"
        case .medium:
            return "Medium"
        case .hard:
            return "Hard"
        }
    }
}

// MARK: - Exploration Mode Enum

/// Represents the exploration mode for treasure hunting
public enum ExplorationMode: String, CaseIterable, Sendable {
    case dowsing = "dowsing"    // Direction guidance mode
    case sonar = "sonar"        // Distance feedback mode
    
    /// Localized description for the exploration mode
    public var localizedDescription: String {
        switch self {
        case .dowsing:
            return "Dowsing Mode"
        case .sonar:
            return "Sonar Mode"
        }
    }
}

// MARK: - Codable Coordinate Helper

/// Helper struct to make CLLocationCoordinate2D Codable
public struct CodableCoordinate: Codable, Sendable {
    public let latitude: Double
    public let longitude: Double
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public init(coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}