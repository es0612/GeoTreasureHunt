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

// MARK: - Feedback Types

/// Represents the intensity level of feedback
public enum FeedbackIntensity: String, CaseIterable, Sendable {
    case weak = "weak"
    case medium = "medium"
    case strong = "strong"
    case veryStrong = "veryStrong"
    
    /// Numeric value for intensity (0.0 to 1.0)
    public var numericValue: Double {
        switch self {
        case .weak:
            return 0.25
        case .medium:
            return 0.5
        case .strong:
            return 0.75
        case .veryStrong:
            return 1.0
        }
    }
}

/// Settings for pulse animation visual feedback
public struct PulseAnimationSettings: Sendable {
    public let frequency: Double // Hz
    public let amplitude: Double // 0.0 to 1.0
    public let duration: Double // seconds
    
    public init(frequency: Double, amplitude: Double, duration: Double) {
        self.frequency = frequency
        self.amplitude = amplitude
        self.duration = duration
    }
}

/// Color representation for visual feedback
public struct FeedbackColor: Sendable {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let alpha: Double
    
    public init(red: Double, green: Double, blue: Double, alpha: Double) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    /// Predefined colors for different intensities
    public static let weakSonar = FeedbackColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 0.3)
    public static let mediumSonar = FeedbackColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 0.5)
    public static let strongSonar = FeedbackColor(red: 0.2, green: 1.0, blue: 0.8, alpha: 0.7)
    public static let veryStrongSonar = FeedbackColor(red: 0.5, green: 1.0, blue: 0.5, alpha: 1.0)
}

// MARK: - Tutorial Types

/// Represents the current step in the tutorial sequence
public enum TutorialStep: String, CaseIterable, Codable, Sendable {
    case welcome = "welcome"
    case dowsingExplanation = "dowsingExplanation"
    case sonarExplanation = "sonarExplanation"
    case practiceMode = "practiceMode"
    case completed = "completed"
    
    /// Localized description for the tutorial step
    public var localizedDescription: String {
        switch self {
        case .welcome:
            return "Welcome"
        case .dowsingExplanation:
            return "Dowsing Mode"
        case .sonarExplanation:
            return "Sonar Mode"
        case .practiceMode:
            return "Practice"
        case .completed:
            return "Completed"
        }
    }
    
    /// Next step in the tutorial sequence
    public var nextStep: TutorialStep? {
        switch self {
        case .welcome:
            return .dowsingExplanation
        case .dowsingExplanation:
            return .sonarExplanation
        case .sonarExplanation:
            return .practiceMode
        case .practiceMode:
            return .completed
        case .completed:
            return nil
        }
    }
}

/// Game settings for audio and haptic feedback
public struct GameSettings: Codable, Equatable, Sendable {
    public let audioEnabled: Bool
    public let hapticsEnabled: Bool
    public let audioVolume: Float // 0.0 to 1.0
    
    public init(audioEnabled: Bool, hapticsEnabled: Bool, audioVolume: Float) {
        self.audioEnabled = audioEnabled
        self.hapticsEnabled = hapticsEnabled
        self.audioVolume = max(0.0, min(1.0, audioVolume)) // Clamp to valid range
    }
    
    /// Default game settings
    public static let `default` = GameSettings(
        audioEnabled: true,
        hapticsEnabled: true,
        audioVolume: 0.8
    )
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