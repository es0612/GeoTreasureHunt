import Testing
import Foundation
import CoreLocation
import GeoSonarCore
import GeoSonarTesting
@testable import GeoSonarUI

@Suite("ExplorationViewModel Tests")
struct ExplorationViewModelTests {
    
    // MARK: - Test Data
    
    private func createTestTreasure() -> Treasure {
        return Treasure(
            id: UUID(),
            coordinate: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753),
            name: "Test Treasure",
            description: "A test treasure",
            points: 100,
            discoveryRadius: 10.0
        )
    }
    
    private func createTestGameSession() -> GameSession {
        return GameSession(
            id: UUID(),
            mapId: UUID(),
            startTime: Date(),
            discoveredTreasures: Set<UUID>(),
            totalPoints: 0,
            isActive: true
        )
    }
    
    private func createTestTreasureMap() -> TreasureMap {
        let treasure = createTestTreasure()
        return TreasureMap(
            id: UUID(),
            name: "Test Map",
            description: "A test treasure map",
            region: MapRegion(
                center: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753),
                span: MapSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ),
            treasures: [treasure],
            difficulty: .easy
        )
    }
    
    // MARK: - Initialization Tests
    
    @Test("ExplorationViewModel initializes with correct default state")
    @MainActor
    func testInitialization() async throws {
        let mockLocationService = MockLocationService()
        let mockExplorationService = MockExplorationService()
        let mockFeedbackService = MockFeedbackService()
        let mockProgressRepo = MockGameProgressRepository()
        
        let testSession = createTestGameSession()
        let testMap = createTestTreasureMap()
        let gameSettings = GameSettings.default
        
        let viewModel = ExplorationViewModel(
            gameSession: testSession,
            treasureMap: testMap,
            gameSettings: gameSettings,
            locationService: mockLocationService,
            explorationService: mockExplorationService,
            feedbackService: mockFeedbackService,
            progressRepository: mockProgressRepo
        )
        
        #expect(viewModel.currentMode == .dowsing)
        #expect(viewModel.nearestTreasure == nil)
        #expect(viewModel.directionToTreasure == 0.0)
        #expect(viewModel.distanceToTreasure == 0.0)
        #expect(viewModel.isLocationPermissionGranted == false)
        #expect(viewModel.errorMessage == nil)
    }
    
    // MARK: - Mode Switching Tests
    
    @Test("switchMode changes exploration mode correctly")
    @MainActor
    func testSwitchMode() async throws {
        let mockLocationService = MockLocationService()
        let mockExplorationService = MockExplorationService()
        let mockFeedbackService = MockFeedbackService()
        let mockProgressRepo = MockGameProgressRepository()
        
        let testSession = createTestGameSession()
        let testMap = createTestTreasureMap()
        let gameSettings = GameSettings.default
        
        let viewModel = ExplorationViewModel(
            gameSession: testSession,
            treasureMap: testMap,
            gameSettings: gameSettings,
            locationService: mockLocationService,
            explorationService: mockExplorationService,
            feedbackService: mockFeedbackService,
            progressRepository: mockProgressRepo
        )
        
        // Test switching to sonar mode
        viewModel.switchMode(to: .sonar)
        #expect(viewModel.currentMode == .sonar)
        
        // Test switching back to dowsing mode
        viewModel.switchMode(to: .dowsing)
        #expect(viewModel.currentMode == .dowsing)
    }
    
    // MARK: - Location Update Tests
    
    @Test("location updates trigger treasure calculations")
    @MainActor
    func testLocationUpdateTriggersCalculations() async throws {
        let mockLocationService = MockLocationService()
        let mockExplorationService = MockExplorationService()
        let mockFeedbackService = MockFeedbackService()
        let mockProgressRepo = MockGameProgressRepository()
        
        let testSession = createTestGameSession()
        let testMap = createTestTreasureMap()
        let gameSettings = GameSettings.default
        
        // Set up mock exploration service
        let testTreasure = testMap.treasures.first!
        mockExplorationService.mockNearestTreasure = testTreasure
        mockExplorationService.mockDistance = 50.0
        mockExplorationService.mockDirection = 45.0
        
        let viewModel = ExplorationViewModel(
            gameSession: testSession,
            treasureMap: testMap,
            gameSettings: gameSettings,
            locationService: mockLocationService,
            explorationService: mockExplorationService,
            feedbackService: mockFeedbackService,
            progressRepository: mockProgressRepo
        )
        
        // Simulate location update
        let testLocation = CLLocation(latitude: 35.7140, longitude: 139.7750)
        mockLocationService.simulateLocationUpdate(testLocation)
        
        // Wait for the location update to be processed
        await viewModel.handleLocationUpdate()
        
        #expect(viewModel.nearestTreasure?.id == testTreasure.id)
        #expect(viewModel.distanceToTreasure == 50.0)
        #expect(viewModel.directionToTreasure == 45.0)
        #expect(mockExplorationService.findNearestTreasureCalls.count == 1)
        #expect(mockExplorationService.calculateDistanceCalls.count == 1)
        #expect(mockExplorationService.calculateDirectionCalls.count == 1)
    }
    
    @Test("location updates filter out discovered treasures")
    @MainActor
    func testLocationUpdateFiltersDiscoveredTreasures() async throws {
        let mockLocationService = MockLocationService()
        let mockExplorationService = MockExplorationService()
        let mockFeedbackService = MockFeedbackService()
        let mockProgressRepo = MockGameProgressRepository()
        
        let testTreasure = createTestTreasure()
        let testMap = TreasureMap(
            id: UUID(),
            name: "Test Map",
            description: "A test treasure map",
            region: MapRegion(
                center: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753),
                span: MapSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ),
            treasures: [testTreasure],
            difficulty: .easy
        )
        
        // Create session with discovered treasure
        var testSession = createTestGameSession()
        testSession.discoveredTreasures.insert(testTreasure.id)
        
        let gameSettings = GameSettings.default
        
        let viewModel = ExplorationViewModel(
            gameSession: testSession,
            treasureMap: testMap,
            gameSettings: gameSettings,
            locationService: mockLocationService,
            explorationService: mockExplorationService,
            feedbackService: mockFeedbackService,
            progressRepository: mockProgressRepo
        )
        
        // Simulate location update
        let testLocation = CLLocation(latitude: 35.7140, longitude: 139.7750)
        mockLocationService.simulateLocationUpdate(testLocation)
        
        await viewModel.handleLocationUpdate()
        
        // Should not find any treasures since the only one is discovered
        #expect(viewModel.nearestTreasure == nil)
        #expect(mockExplorationService.findNearestTreasureCalls.count == 1)
        
        // Check that the filtered treasures array was empty
        let lastCall = mockExplorationService.findNearestTreasureCalls.last!
        #expect(lastCall.1.isEmpty) // Second element is the treasures array
    }
    
    // MARK: - Sonar Ping Tests
    
    @Test("sendSonarPing provides feedback when location available")
    @MainActor
    func testSendSonarPingWithLocation() async throws {
        let mockLocationService = MockLocationService()
        let mockExplorationService = MockExplorationService()
        let mockFeedbackService = MockFeedbackService()
        let mockProgressRepo = MockGameProgressRepository()
        
        let testSession = createTestGameSession()
        let testMap = createTestTreasureMap()
        let gameSettings = GameSettings.default
        
        // Set up mocks
        let testTreasure = testMap.treasures.first!
        mockExplorationService.mockNearestTreasure = testTreasure
        mockExplorationService.mockDistance = 25.0
        mockFeedbackService.mockSonarFeedbackSuccess = true
        
        let viewModel = ExplorationViewModel(
            gameSession: testSession,
            treasureMap: testMap,
            gameSettings: gameSettings,
            locationService: mockLocationService,
            explorationService: mockExplorationService,
            feedbackService: mockFeedbackService,
            progressRepository: mockProgressRepo
        )
        
        // Set up location
        let testLocation = CLLocation(latitude: 35.7140, longitude: 139.7750)
        mockLocationService.simulateLocationUpdate(testLocation)
        await viewModel.handleLocationUpdate()
        
        // Send sonar ping
        let success = await viewModel.sendSonarPing()
        
        #expect(success == true)
        #expect(mockFeedbackService.provideSonarFeedbackCalls.count == 1)
        #expect(mockFeedbackService.provideSonarFeedbackCalls.first?.0 == 25.0)
    }
    
    @Test("sendSonarPing fails when no location available")
    @MainActor
    func testSendSonarPingWithoutLocation() async throws {
        let mockLocationService = MockLocationService()
        let mockExplorationService = MockExplorationService()
        let mockFeedbackService = MockFeedbackService()
        let mockProgressRepo = MockGameProgressRepository()
        
        let testSession = createTestGameSession()
        let testMap = createTestTreasureMap()
        let gameSettings = GameSettings.default
        
        let viewModel = ExplorationViewModel(
            gameSession: testSession,
            treasureMap: testMap,
            gameSettings: gameSettings,
            locationService: mockLocationService,
            explorationService: mockExplorationService,
            feedbackService: mockFeedbackService,
            progressRepository: mockProgressRepo
        )
        
        // Don't set up location
        let success = await viewModel.sendSonarPing()
        
        #expect(success == false)
        #expect(mockFeedbackService.provideSonarFeedbackCalls.isEmpty)
    }
    
    // MARK: - Treasure Discovery Tests
    
    @Test("checkForTreasureDiscovery discovers treasure and updates session")
    @MainActor
    func testTreasureDiscovery() async throws {
        let mockLocationService = MockLocationService()
        let mockExplorationService = MockExplorationService()
        let mockFeedbackService = MockFeedbackService()
        let mockProgressRepo = MockGameProgressRepository()
        
        let testSession = createTestGameSession()
        let testMap = createTestTreasureMap()
        let gameSettings = GameSettings.default
        
        // Set up mock to return discovered treasure
        let testTreasure = testMap.treasures.first!
        mockExplorationService.mockDiscoveredTreasure = testTreasure
        
        let viewModel = ExplorationViewModel(
            gameSession: testSession,
            treasureMap: testMap,
            gameSettings: gameSettings,
            locationService: mockLocationService,
            explorationService: mockExplorationService,
            feedbackService: mockFeedbackService,
            progressRepository: mockProgressRepo
        )
        
        // Set up location
        let testLocation = CLLocation(latitude: 35.7148, longitude: 139.7753) // Same as treasure
        mockLocationService.simulateLocationUpdate(testLocation)
        
        // Check for treasure discovery
        let discoveredTreasure = await viewModel.checkForTreasureDiscovery()
        
        #expect(discoveredTreasure?.id == testTreasure.id)
        #expect(viewModel.currentSession.discoveredTreasures.contains(testTreasure.id))
        #expect(viewModel.currentSession.totalPoints == testTreasure.points)
        #expect(mockProgressRepo.saveProgressWasCalledCount == 1)
        #expect(mockExplorationService.checkTreasureDiscoveryCalls.count == 1)
    }
    
    @Test("checkForTreasureDiscovery returns nil when no treasure discovered")
    @MainActor
    func testNoTreasureDiscovery() async throws {
        let mockLocationService = MockLocationService()
        let mockExplorationService = MockExplorationService()
        let mockFeedbackService = MockFeedbackService()
        let mockProgressRepo = MockGameProgressRepository()
        
        let testSession = createTestGameSession()
        let testMap = createTestTreasureMap()
        let gameSettings = GameSettings.default
        
        // Set up mock to return no discovered treasure
        mockExplorationService.mockDiscoveredTreasure = nil
        
        let viewModel = ExplorationViewModel(
            gameSession: testSession,
            treasureMap: testMap,
            gameSettings: gameSettings,
            locationService: mockLocationService,
            explorationService: mockExplorationService,
            feedbackService: mockFeedbackService,
            progressRepository: mockProgressRepo
        )
        
        // Set up location
        let testLocation = CLLocation(latitude: 35.7140, longitude: 139.7750) // Far from treasure
        mockLocationService.simulateLocationUpdate(testLocation)
        
        // Check for treasure discovery
        let discoveredTreasure = await viewModel.checkForTreasureDiscovery()
        
        #expect(discoveredTreasure == nil)
        #expect(viewModel.currentSession.discoveredTreasures.isEmpty)
        #expect(viewModel.currentSession.totalPoints == 0)
        #expect(mockProgressRepo.saveProgressWasCalledCount == 0)
    }
    
    @Test("checkForTreasureDiscovery handles already discovered treasure")
    @MainActor
    func testAlreadyDiscoveredTreasure() async throws {
        let mockLocationService = MockLocationService()
        let mockExplorationService = MockExplorationService()
        let mockFeedbackService = MockFeedbackService()
        let mockProgressRepo = MockGameProgressRepository()
        
        let testTreasure = createTestTreasure()
        let testMap = TreasureMap(
            id: UUID(),
            name: "Test Map",
            description: "A test treasure map",
            region: MapRegion(
                center: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753),
                span: MapSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ),
            treasures: [testTreasure],
            difficulty: .easy
        )
        
        // Create session with already discovered treasure
        var testSession = createTestGameSession()
        testSession.discoveredTreasures.insert(testTreasure.id)
        testSession.totalPoints = testTreasure.points
        
        let gameSettings = GameSettings.default
        
        // Set up mock to return the already discovered treasure
        mockExplorationService.mockDiscoveredTreasure = testTreasure
        
        let viewModel = ExplorationViewModel(
            gameSession: testSession,
            treasureMap: testMap,
            gameSettings: gameSettings,
            locationService: mockLocationService,
            explorationService: mockExplorationService,
            feedbackService: mockFeedbackService,
            progressRepository: mockProgressRepo
        )
        
        // Set up location
        let testLocation = CLLocation(latitude: 35.7148, longitude: 139.7753)
        mockLocationService.simulateLocationUpdate(testLocation)
        
        // Check for treasure discovery
        let discoveredTreasure = await viewModel.checkForTreasureDiscovery()
        
        #expect(discoveredTreasure == nil) // Should return nil for already discovered
        #expect(viewModel.currentSession.totalPoints == testTreasure.points) // Points unchanged
        #expect(mockProgressRepo.saveProgressWasCalledCount == 0) // No save needed
    }
    
    // MARK: - Permission Handling Tests
    
    @Test("startLocationTracking requests permission and starts updates")
    @MainActor
    func testStartLocationTracking() async throws {
        let mockLocationService = MockLocationService()
        let mockExplorationService = MockExplorationService()
        let mockFeedbackService = MockFeedbackService()
        let mockProgressRepo = MockGameProgressRepository()
        
        let testSession = createTestGameSession()
        let testMap = createTestTreasureMap()
        let gameSettings = GameSettings.default
        
        let viewModel = ExplorationViewModel(
            gameSession: testSession,
            treasureMap: testMap,
            gameSettings: gameSettings,
            locationService: mockLocationService,
            explorationService: mockExplorationService,
            feedbackService: mockFeedbackService,
            progressRepository: mockProgressRepo
        )
        
        // Start location tracking
        await viewModel.startLocationTracking()
        
        #expect(viewModel.isLocationPermissionGranted == true)
        #expect(mockLocationService.isLocationUpdating == true)
    }
    
    @Test("stopLocationTracking stops location updates")
    @MainActor
    func testStopLocationTracking() async throws {
        let mockLocationService = MockLocationService()
        let mockExplorationService = MockExplorationService()
        let mockFeedbackService = MockFeedbackService()
        let mockProgressRepo = MockGameProgressRepository()
        
        let testSession = createTestGameSession()
        let testMap = createTestTreasureMap()
        let gameSettings = GameSettings.default
        
        let viewModel = ExplorationViewModel(
            gameSession: testSession,
            treasureMap: testMap,
            gameSettings: gameSettings,
            locationService: mockLocationService,
            explorationService: mockExplorationService,
            feedbackService: mockFeedbackService,
            progressRepository: mockProgressRepo
        )
        
        // Start then stop location tracking
        await viewModel.startLocationTracking()
        viewModel.stopLocationTracking()
        
        #expect(mockLocationService.isLocationUpdating == false)
    }
}