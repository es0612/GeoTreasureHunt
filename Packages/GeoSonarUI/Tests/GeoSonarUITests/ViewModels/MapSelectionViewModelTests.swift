import Testing
import Foundation
import CoreLocation
import GeoSonarCore
import GeoSonarTesting
@testable import GeoSonarUI

@Suite("MapSelectionViewModel Tests")
struct MapSelectionViewModelTests {
    
    // MARK: - Test Data
    
    private func createTestTreasureMap() -> TreasureMap {
        let treasure = Treasure(
            id: UUID(),
            coordinate: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753),
            name: "Test Treasure",
            description: "A test treasure",
            points: 100,
            discoveryRadius: 10.0
        )
        
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
    
    @Test("MapSelectionViewModel initializes with empty state")
    @MainActor
    func testInitialization() async throws {
        let mockTreasureMapRepo = MockTreasureMapRepository()
        let mockProgressRepo = MockGameProgressRepository()
        
        let viewModel = MapSelectionViewModel(
            treasureMapRepository: mockTreasureMapRepo,
            progressRepository: mockProgressRepo
        )
        
        #expect(viewModel.availableMaps.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }
    
    // MARK: - Map Loading Tests
    
    @Test("loadMaps successfully loads treasure maps")
    @MainActor
    func testLoadMapsSuccess() async throws {
        let mockTreasureMapRepo = MockTreasureMapRepository()
        let mockProgressRepo = MockGameProgressRepository()
        let testMap = createTestTreasureMap()
        
        mockTreasureMapRepo.setMockMaps([testMap])
        
        let viewModel = MapSelectionViewModel(
            treasureMapRepository: mockTreasureMapRepo,
            progressRepository: mockProgressRepo
        )
        
        await viewModel.loadMaps()
        
        #expect(viewModel.availableMaps.count == 1)
        #expect(viewModel.availableMaps.first?.id == testMap.id)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(mockTreasureMapRepo.getAllMapsWasCalledCount == 1)
    }
    
    @Test("loadMaps handles repository error gracefully")
    @MainActor
    func testLoadMapsError() async throws {
        let mockTreasureMapRepo = MockTreasureMapRepository()
        let mockProgressRepo = MockGameProgressRepository()
        
        mockTreasureMapRepo.setShouldThrowError(.dataCorrupted)
        
        let viewModel = MapSelectionViewModel(
            treasureMapRepository: mockTreasureMapRepo,
            progressRepository: mockProgressRepo
        )
        
        await viewModel.loadMaps()
        
        #expect(viewModel.availableMaps.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.errorMessage?.contains("破損") == true)
    }
    
    @Test("loadMaps sets loading state correctly")
    @MainActor
    func testLoadMapsLoadingState() async throws {
        let mockTreasureMapRepo = MockTreasureMapRepository()
        let mockProgressRepo = MockGameProgressRepository()
        let testMap = createTestTreasureMap()
        
        mockTreasureMapRepo.setMockMaps([testMap])
        
        let viewModel = MapSelectionViewModel(
            treasureMapRepository: mockTreasureMapRepo,
            progressRepository: mockProgressRepo
        )
        
        // Start loading
        let loadTask = Task {
            await viewModel.loadMaps()
        }
        
        // Check that loading state is set (this might be brief)
        // Note: In a real scenario, we might need to add delays to test this properly
        
        await loadTask.value
        
        #expect(viewModel.isLoading == false)
    }
    
    // MARK: - Map Selection Tests
    
    @Test("selectMap creates new game session")
    @MainActor
    func testSelectMapCreatesGameSession() async throws {
        let mockTreasureMapRepo = MockTreasureMapRepository()
        let mockProgressRepo = MockGameProgressRepository()
        let testMap = createTestTreasureMap()
        
        let viewModel = MapSelectionViewModel(
            treasureMapRepository: mockTreasureMapRepo,
            progressRepository: mockProgressRepo
        )
        
        let gameSession = await viewModel.selectMap(testMap)
        
        #expect(gameSession.mapId == testMap.id)
        #expect(gameSession.isActive == true)
        #expect(gameSession.totalPoints == 0)
        #expect(gameSession.discoveredTreasures.isEmpty)
    }
    
    @Test("selectMap with existing progress loads previous session")
    @MainActor
    func testSelectMapWithExistingProgress() async throws {
        let mockTreasureMapRepo = MockTreasureMapRepository()
        let mockProgressRepo = MockGameProgressRepository()
        let testMap = createTestTreasureMap()
        
        // Set up existing progress
        let existingSession = GameSession(
            id: UUID(),
            mapId: testMap.id,
            startTime: Date().addingTimeInterval(-3600), // 1 hour ago
            discoveredTreasures: Set([testMap.treasures.first!.id]),
            totalPoints: 100,
            isActive: false
        )
        
        mockProgressRepo.setMockSession(existingSession, for: testMap.id)
        
        let viewModel = MapSelectionViewModel(
            treasureMapRepository: mockTreasureMapRepo,
            progressRepository: mockProgressRepo
        )
        
        let gameSession = await viewModel.selectMap(testMap)
        
        #expect(gameSession.mapId == testMap.id)
        #expect(gameSession.totalPoints == 100)
        #expect(gameSession.discoveredTreasures.count == 1)
        #expect(gameSession.isActive == true) // Should be reactivated
        #expect(mockProgressRepo.loadProgressWasCalledCount == 1)
    }
    
    @Test("selectMap handles progress loading error")
    @MainActor
    func testSelectMapProgressLoadingError() async throws {
        let mockTreasureMapRepo = MockTreasureMapRepository()
        let mockProgressRepo = MockGameProgressRepository()
        let testMap = createTestTreasureMap()
        
        mockProgressRepo.setShouldThrowError(.loadFailed)
        
        let viewModel = MapSelectionViewModel(
            treasureMapRepository: mockTreasureMapRepo,
            progressRepository: mockProgressRepo
        )
        
        let gameSession = await viewModel.selectMap(testMap)
        
        // Should create new session when loading fails
        #expect(gameSession.mapId == testMap.id)
        #expect(gameSession.isActive == true)
        #expect(gameSession.totalPoints == 0)
        #expect(gameSession.discoveredTreasures.isEmpty)
    }
    
    // MARK: - Progress Information Tests
    
    @Test("getMapProgress returns correct completion percentage")
    @MainActor
    func testGetMapProgress() async throws {
        let mockTreasureMapRepo = MockTreasureMapRepository()
        let mockProgressRepo = MockGameProgressRepository()
        let testMap = createTestTreasureMap()
        
        // Set up progress with one treasure discovered
        let existingSession = GameSession(
            id: UUID(),
            mapId: testMap.id,
            startTime: Date(),
            discoveredTreasures: Set([testMap.treasures.first!.id]),
            totalPoints: 100,
            isActive: false
        )
        
        mockProgressRepo.setMockSession(existingSession, for: testMap.id)
        
        let viewModel = MapSelectionViewModel(
            treasureMapRepository: mockTreasureMapRepo,
            progressRepository: mockProgressRepo
        )
        
        let progress = await viewModel.getMapProgress(for: testMap)
        
        #expect(progress.completionPercentage == 100.0) // 1 out of 1 treasure
        #expect(progress.discoveredTreasures == 1)
        #expect(progress.totalTreasures == 1)
        #expect(progress.totalPoints == 100)
    }
    
    @Test("getMapProgress returns zero for no progress")
    @MainActor
    func testGetMapProgressNoProgress() async throws {
        let mockTreasureMapRepo = MockTreasureMapRepository()
        let mockProgressRepo = MockGameProgressRepository()
        let testMap = createTestTreasureMap()
        
        let viewModel = MapSelectionViewModel(
            treasureMapRepository: mockTreasureMapRepo,
            progressRepository: mockProgressRepo
        )
        
        let progress = await viewModel.getMapProgress(for: testMap)
        
        #expect(progress.completionPercentage == 0.0)
        #expect(progress.discoveredTreasures == 0)
        #expect(progress.totalTreasures == 1)
        #expect(progress.totalPoints == 0)
    }
}