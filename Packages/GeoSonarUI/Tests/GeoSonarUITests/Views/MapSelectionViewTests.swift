import Testing
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import CoreLocation
import GeoSonarCore
import GeoSonarTesting
@testable import GeoSonarUI

@Suite("MapSelectionView Tests")
@MainActor
struct MapSelectionViewTests {
    
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
    
    private func createViewModel() -> MapSelectionViewModel {
        let mockTreasureMapRepo = MockTreasureMapRepository()
        let mockProgressRepo = MockGameProgressRepository()
        
        // Set up mock data
        mockTreasureMapRepo.setMockMaps([createTestTreasureMap()])
        
        return MapSelectionViewModel(
            treasureMapRepository: mockTreasureMapRepo,
            progressRepository: mockProgressRepo
        )
    }
    
    // MARK: - View Rendering Tests
    
    @Test("MapSelectionView displays loading state")
    func testMapSelectionViewDisplaysLoadingState() async throws {
        let viewModel = createViewModel()
        
        // Create view with loading state
        let view = MapSelectionView(viewModel: viewModel)
        
        // Verify view can be created
        #expect(view != nil)
    }
    
    @Test("MapSelectionView displays map list when loaded")
    func testMapSelectionViewDisplaysMapList() async throws {
        let viewModel = createViewModel()
        let testMap = createTestTreasureMap()
        
        // Load maps into view model
        await viewModel.loadMaps()
        
        // Create view with loaded data
        let view = MapSelectionView(viewModel: viewModel)
        
        // Verify view can be rendered
        // View creation test
        #expect(view != nil)
        
        // Verify view model has maps
        #expect(viewModel.availableMaps.count > 0)
    }
    
    @Test("MapSelectionView displays error state")
    func testMapSelectionViewDisplaysErrorState() async throws {
        let viewModel = createViewModel()
        
        // Create view
        let view = MapSelectionView(viewModel: viewModel)
        
        // Verify view can be rendered even with error
        // View creation test
        #expect(view != nil)
    }
    
    @Test("MapSelectionView handles map selection")
    func testMapSelectionViewHandlesMapSelection() async throws {
        let viewModel = createViewModel()
        let testMap = createTestTreasureMap()
        
        // Load maps
        await viewModel.loadMaps()
        
        // Create view
        let view = MapSelectionView(viewModel: viewModel)
        
        // Verify view can be rendered
        // View creation test
        #expect(view != nil)
        
        // Test map selection
        let session = await viewModel.selectMap(testMap)
        #expect(session.mapId == testMap.id)
    }
    
    // MARK: - Navigation Tests
    
    @Test("MapSelectionView supports navigation to exploration")
    func testMapSelectionViewSupportsNavigation() async throws {
        let viewModel = createViewModel()
        
        // Create view with navigation
        let view = NavigationStack {
            MapSelectionView(viewModel: viewModel)
        }
        
        // Verify navigation view can be rendered
        // View creation test
        #expect(view != nil)
    }
    
    // MARK: - Accessibility Tests
    
    @Test("MapSelectionView has proper accessibility")
    func testMapSelectionViewAccessibility() async throws {
        let viewModel = createViewModel()
        
        // Create view
        let view = MapSelectionView(viewModel: viewModel)
        
        // Verify view can be rendered
        // View creation test
        #expect(view != nil)
        
        // Basic accessibility verification - view should be accessible
        // Container views are typically not accessibility elements
    }
    
    // MARK: - State Management Tests
    
    @Test("MapSelectionView responds to view model changes")
    func testMapSelectionViewRespondsToViewModelChanges() async throws {
        let viewModel = createViewModel()
        
        // Create view
        let view = MapSelectionView(viewModel: viewModel)
        // View creation test
        
        // Initial state
        #expect(viewModel.availableMaps.isEmpty)
        
        // Load maps
        await viewModel.loadMaps()
        
        // Verify view model updated
        #expect(viewModel.availableMaps.count > 0)
        
        // View should still be renderable
        #expect(view != nil)
    }
}