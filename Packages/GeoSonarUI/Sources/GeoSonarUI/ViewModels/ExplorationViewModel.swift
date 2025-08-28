import Foundation
import CoreLocation
import Combine
import GeoSonarCore

/// ViewModel for managing treasure exploration and real-time location tracking
@available(iOS 17.0, macOS 14.0, *)
@Observable
@MainActor
public final class ExplorationViewModel: Sendable {
    
    // MARK: - Dependencies
    
    private let locationService: any LocationServiceProtocol
    private let explorationService: ExplorationServiceProtocol
    private let feedbackService: FeedbackServiceProtocol
    private let progressRepository: GameProgressRepository
    
    // MARK: - Game State
    
    public private(set) var currentSession: GameSession
    public private(set) var treasureMap: TreasureMap
    public private(set) var gameSettings: GameSettings
    
    // MARK: - Exploration State
    
    public private(set) var currentMode: ExplorationMode = .dowsing
    public private(set) var nearestTreasure: Treasure?
    public private(set) var directionToTreasure: Double = 0.0
    public private(set) var distanceToTreasure: Double = 0.0
    
    // MARK: - UI State
    
    public private(set) var isLocationPermissionGranted: Bool = false
    public private(set) var errorMessage: String?
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init(
        gameSession: GameSession,
        treasureMap: TreasureMap,
        gameSettings: GameSettings,
        locationService: any LocationServiceProtocol,
        explorationService: ExplorationServiceProtocol,
        feedbackService: FeedbackServiceProtocol,
        progressRepository: GameProgressRepository
    ) {
        self.currentSession = gameSession
        self.treasureMap = treasureMap
        self.gameSettings = gameSettings
        self.locationService = locationService
        self.explorationService = explorationService
        self.feedbackService = feedbackService
        self.progressRepository = progressRepository
        
        setupLocationObservation()
    }
    
    // MARK: - Public Methods
    
    /// Switches the exploration mode between dowsing and sonar
    /// - Parameter mode: The exploration mode to switch to
    public func switchMode(to mode: ExplorationMode) {
        currentMode = mode
    }
    
    /// Sends a sonar ping and provides distance-based feedback
    /// - Returns: True if sonar ping was successful, false otherwise
    public func sendSonarPing() async -> Bool {
        guard let currentLocation = locationService.currentLocation,
              let nearestTreasure = nearestTreasure else {
            return false
        }
        
        let distance = explorationService.calculateDistance(
            from: currentLocation,
            to: nearestTreasure.coordinate
        )
        
        return await feedbackService.provideSonarFeedback(
            distance: distance,
            settings: gameSettings
        )
    }
    
    /// Checks if any treasure can be discovered from the current location
    /// - Returns: The discovered treasure, or nil if none discovered
    public func checkForTreasureDiscovery() async -> Treasure? {
        guard let currentLocation = locationService.currentLocation else {
            return nil
        }
        
        // Filter out already discovered treasures
        let undiscoveredTreasures = treasureMap.treasures.filter { treasure in
            !currentSession.discoveredTreasures.contains(treasure.id)
        }
        
        guard let discoveredTreasure = explorationService.checkTreasureDiscovery(
            userLocation: currentLocation,
            treasures: undiscoveredTreasures
        ) else {
            return nil
        }
        
        // Check if this treasure was already discovered (double-check)
        guard !currentSession.discoveredTreasures.contains(discoveredTreasure.id) else {
            return nil
        }
        
        // Update session with discovered treasure
        let wasNewDiscovery = currentSession.discoverTreasure(
            discoveredTreasure.id,
            points: discoveredTreasure.points
        )
        
        if wasNewDiscovery {
            // Save progress
            do {
                try await progressRepository.saveProgress(currentSession)
            } catch {
                errorMessage = "進捗の保存に失敗しました"
            }
            
            return discoveredTreasure
        }
        
        return nil
    }
    
    /// Starts location tracking and requests permission if needed
    public func startLocationTracking() async {
        // Check current authorization status
        updateLocationPermissionStatus()
        
        if !isLocationPermissionGranted {
            locationService.requestLocationPermission()
            // Wait a bit for permission to be processed
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            updateLocationPermissionStatus()
        }
        
        if isLocationPermissionGranted {
            do {
                try locationService.startLocationUpdates()
            } catch let error as LocationServiceError {
                errorMessage = error.localizedDescription
            } catch {
                errorMessage = "位置情報の取得を開始できませんでした"
            }
        }
    }
    
    /// Stops location tracking
    public func stopLocationTracking() {
        locationService.stopLocationUpdates()
    }
    
    /// Handles location updates and recalculates treasure information
    public func handleLocationUpdate() async {
        guard let currentLocation = locationService.currentLocation else {
            nearestTreasure = nil
            directionToTreasure = 0.0
            distanceToTreasure = 0.0
            return
        }
        
        // Filter out discovered treasures
        let undiscoveredTreasures = treasureMap.treasures.filter { treasure in
            !currentSession.discoveredTreasures.contains(treasure.id)
        }
        
        // Find nearest undiscovered treasure
        guard let nearest = explorationService.findNearestTreasure(
            from: currentLocation,
            in: undiscoveredTreasures
        ) else {
            nearestTreasure = nil
            directionToTreasure = 0.0
            distanceToTreasure = 0.0
            return
        }
        
        nearestTreasure = nearest
        
        // Calculate distance and direction
        distanceToTreasure = explorationService.calculateDistance(
            from: currentLocation,
            to: nearest.coordinate
        )
        
        directionToTreasure = explorationService.calculateDirection(
            from: currentLocation,
            to: nearest.coordinate
        )
    }
    
    /// Updates game settings
    /// - Parameter settings: New game settings
    public func updateGameSettings(_ settings: GameSettings) {
        gameSettings = settings
    }
    
    /// Clears any error message
    public func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    
    private func setupLocationObservation() {
        // For now, we'll handle location updates manually
        // In a real implementation, we would set up proper observation
        // This is a limitation of the current mock setup
    }
    
    private func updateLocationPermissionStatus() {
        #if os(iOS)
        isLocationPermissionGranted = locationService.authorizationStatus == .authorizedWhenInUse ||
                                     locationService.authorizationStatus == .authorizedAlways
        #else
        isLocationPermissionGranted = locationService.authorizationStatus == .authorizedAlways
        #endif
    }
}