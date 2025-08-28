import Foundation
import CoreLocation
import GeoSonarCore

/// Progress information for a treasure map
public struct MapProgress: Sendable {
    public let completionPercentage: Double
    public let discoveredTreasures: Int
    public let totalTreasures: Int
    public let totalPoints: Int
    
    public init(completionPercentage: Double, discoveredTreasures: Int, totalTreasures: Int, totalPoints: Int) {
        self.completionPercentage = completionPercentage
        self.discoveredTreasures = discoveredTreasures
        self.totalTreasures = totalTreasures
        self.totalPoints = totalPoints
    }
}

/// ViewModel for managing treasure map selection and display
@available(iOS 17.0, macOS 14.0, *)
@Observable
@MainActor
public final class MapSelectionViewModel: Sendable {
    
    // MARK: - Dependencies
    
    private let treasureMapRepository: TreasureMapRepository
    private let progressRepository: GameProgressRepository
    
    // MARK: - Published Properties
    
    public private(set) var availableMaps: [TreasureMap] = []
    public private(set) var isLoading: Bool = false
    public private(set) var errorMessage: String?
    
    // MARK: - Initialization
    
    public init(
        treasureMapRepository: TreasureMapRepository,
        progressRepository: GameProgressRepository
    ) {
        self.treasureMapRepository = treasureMapRepository
        self.progressRepository = progressRepository
    }
    
    // MARK: - Public Methods
    
    /// Loads all available treasure maps from the repository
    public func loadMaps() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let maps = try await treasureMapRepository.getAllMaps()
            availableMaps = maps
        } catch let error as TreasureMapRepositoryError {
            errorMessage = error.localizedDescription
            availableMaps = []
        } catch {
            errorMessage = "地図の読み込みに失敗しました"
            availableMaps = []
        }
        
        isLoading = false
    }
    
    /// Selects a treasure map and creates or loads a game session
    /// - Parameter map: The treasure map to select
    /// - Returns: A game session for the selected map
    public func selectMap(_ map: TreasureMap) async -> GameSession {
        // Try to load existing progress
        do {
            if let existingSession = try await progressRepository.loadProgress(for: map.id) {
                // Reactivate existing session
                var reactivatedSession = existingSession
                reactivatedSession.isActive = true
                return reactivatedSession
            }
        } catch {
            // If loading fails, we'll create a new session
        }
        
        // Create new game session
        return GameSession(
            id: UUID(),
            mapId: map.id,
            startTime: Date(),
            discoveredTreasures: Set<UUID>(),
            totalPoints: 0,
            isActive: true
        )
    }
    
    /// Gets progress information for a specific treasure map
    /// - Parameter map: The treasure map to get progress for
    /// - Returns: Progress information for the map
    public func getMapProgress(for map: TreasureMap) async -> MapProgress {
        do {
            if let session = try await progressRepository.loadProgress(for: map.id) {
                let totalTreasures = map.treasures.count
                let discoveredCount = session.discoveredTreasures.count
                let completionPercentage = totalTreasures > 0 ? (Double(discoveredCount) / Double(totalTreasures)) * 100.0 : 0.0
                
                return MapProgress(
                    completionPercentage: completionPercentage,
                    discoveredTreasures: discoveredCount,
                    totalTreasures: totalTreasures,
                    totalPoints: session.totalPoints
                )
            }
        } catch {
            // If loading fails, return zero progress
        }
        
        // No progress found
        return MapProgress(
            completionPercentage: 0.0,
            discoveredTreasures: 0,
            totalTreasures: map.treasures.count,
            totalPoints: 0
        )
    }
    
    /// Clears any error message
    public func clearError() {
        errorMessage = nil
    }
}