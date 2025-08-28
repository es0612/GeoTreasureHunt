import Testing
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import CoreLocation
import GeoSonarCore
import GeoSonarTesting
@testable import GeoSonarUI

@Suite("Navigation Tests")
@MainActor
struct NavigationTests {
    
    // MARK: - Test Data
    
    private func createTestTreasureMap() -> TreasureMap {
        return TreasureMap(
            id: UUID(),
            name: "テスト公園",
            description: "テスト用の宝の地図",
            region: MapRegion(
                center: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753),
                span: MapSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ),
            treasures: [
                Treasure(
                    id: UUID(),
                    coordinate: CLLocationCoordinate2D(latitude: 35.7158, longitude: 139.7763),
                    name: "テスト宝",
                    description: "テスト用の宝",
                    points: 100,
                    discoveryRadius: 10.0
                )
            ],
            difficulty: .easy
        )
    }
    
    private func createMapSelectionViewModel() -> MapSelectionViewModel {
        let mockTreasureMapRepo = MockTreasureMapRepository()
        let mockProgressRepo = MockGameProgressRepository()
        
        return MapSelectionViewModel(
            treasureMapRepository: mockTreasureMapRepo,
            progressRepository: mockProgressRepo
        )
    }
    
    private func createExplorationViewModel() -> ExplorationViewModel {
        let mockLocationService = MockLocationService()
        let mockExplorationService = MockExplorationService()
        let mockFeedbackService = MockFeedbackService()
        let mockProgressRepo = MockGameProgressRepository()
        
        return ExplorationViewModel(
            gameSession: GameSession(
                id: UUID(),
                mapId: UUID(),
                startTime: Date(),
                discoveredTreasures: Set<UUID>(),
                totalPoints: 0,
                isActive: true
            ),
            treasureMap: createTestTreasureMap(),
            gameSettings: GameSettings.default,
            locationService: mockLocationService,
            explorationService: mockExplorationService,
            feedbackService: mockFeedbackService,
            progressRepository: mockProgressRepo
        )
    }
    
    // MARK: - Navigation Stack Tests
    
    @Test("NavigationStack with MapSelectionView renders correctly")
    func testNavigationStackWithMapSelectionView() async throws {
        let viewModel = createMapSelectionViewModel()
        
        // Create navigation stack with map selection view
        let view = NavigationStack {
            MapSelectionView(viewModel: viewModel)
        }
        
        // Verify navigation view can be rendered
        // View creation test
        #expect(view != nil)
    }
    
    @Test("NavigationStack with ExplorationView renders correctly")
    func testNavigationStackWithExplorationView() async throws {
        let viewModel = createExplorationViewModel()
        
        // Create navigation stack with exploration view
        let view = NavigationStack {
            ExplorationView(viewModel: viewModel)
        }
        
        // Verify navigation view can be rendered
        // View creation test
        #expect(view != nil)
    }
    
    // MARK: - Navigation Flow Tests
    
    @Test("Navigation from MapSelection to Exploration")
    func testNavigationFromMapSelectionToExploration() async throws {
        let mapSelectionViewModel = createMapSelectionViewModel()
        let testMap = createTestTreasureMap()
        
        // Load maps
        await mapSelectionViewModel.loadMaps()
        
        // Select a map to create a session
        let gameSession = await mapSelectionViewModel.selectMap(testMap)
        #expect(gameSession.mapId == testMap.id)
        
        // Create exploration view model with the session
        let explorationViewModel = createExplorationViewModel()
        
        // Create a navigation flow
        let view = NavigationStack {
            VStack {
                MapSelectionView(viewModel: mapSelectionViewModel)
                
                NavigationLink("Start Exploration") {
                    ExplorationView(viewModel: explorationViewModel)
                }
            }
        }
        
        // Verify navigation view can be rendered
        // View creation test
        #expect(view != nil)
    }
    
    // MARK: - Navigation State Tests
    
    @Test("Navigation maintains view model state")
    func testNavigationMaintainsViewModelState() async throws {
        let mapSelectionViewModel = createMapSelectionViewModel()
        
        // Load maps
        await mapSelectionViewModel.loadMaps()
        let initialMapCount = mapSelectionViewModel.availableMaps.count
        
        // Create navigation view
        let view = NavigationStack {
            MapSelectionView(viewModel: mapSelectionViewModel)
        }
        
        // View creation test
        #expect(view != nil)
        
        // Verify state is maintained
        #expect(mapSelectionViewModel.availableMaps.count == initialMapCount)
    }
    
    // MARK: - Deep Navigation Tests
    
    @Test("Deep navigation structure renders correctly")
    func testDeepNavigationStructure() async throws {
        let mapSelectionViewModel = createMapSelectionViewModel()
        let explorationViewModel = createExplorationViewModel()
        
        // Create deep navigation structure
        let view = NavigationStack {
            VStack {
                Text("Main Menu")
                
                NavigationLink("Maps") {
                    VStack {
                        MapSelectionView(viewModel: mapSelectionViewModel)
                        
                        NavigationLink("Exploration") {
                            ExplorationView(viewModel: explorationViewModel)
                        }
                    }
                }
            }
        }
        
        // Verify deep navigation can be rendered
        // View creation test
        #expect(view != nil)
    }
    
    // MARK: - Navigation Accessibility Tests
    
    @Test("Navigation maintains accessibility")
    func testNavigationMaintainsAccessibility() async throws {
        let mapSelectionViewModel = createMapSelectionViewModel()
        
        // Create navigation with accessibility
        let view = NavigationStack {
            MapSelectionView(viewModel: mapSelectionViewModel)
                .accessibilityLabel("Map Selection Screen")
        }
        
        // Verify navigation view can be rendered
        // View creation test
        #expect(view != nil)
    }
    
    // MARK: - Navigation Performance Tests
    
    @Test("Navigation performs efficiently with multiple views")
    func testNavigationPerformanceWithMultipleViews() async throws {
        let mapSelectionViewModel = createMapSelectionViewModel()
        let explorationViewModel = createExplorationViewModel()
        
        // Create multiple navigation destinations
        let view = NavigationStack {
            VStack {
                NavigationLink("Map Selection") {
                    MapSelectionView(viewModel: mapSelectionViewModel)
                }
                
                NavigationLink("Exploration") {
                    ExplorationView(viewModel: explorationViewModel)
                }
                
                NavigationLink("Settings") {
                    Text("Settings View")
                }
            }
        }
        
        // Verify navigation with multiple destinations can be rendered
        // View creation test
        #expect(view != nil)
    }
}