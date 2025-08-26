import Foundation
import GeoSonarCore

/// Mock implementation of TreasureMapRepository for testing purposes
public final class MockTreasureMapRepository: TreasureMapRepository, @unchecked Sendable {
    
    // MARK: - Mock Data Storage
    
    private var mockMaps: [TreasureMap] = []
    private var shouldThrowError: TreasureMapRepositoryError?
    private var getAllMapsCallCount = 0
    private var getMapCallCount = 0
    private var mapExistsCallCount = 0
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - Mock Configuration Methods
    
    /// Sets the mock data to be returned by repository methods
    /// - Parameter maps: Array of treasure maps to return
    public func setMockMaps(_ maps: [TreasureMap]) {
        mockMaps = maps
    }
    
    /// Configures the repository to throw an error on the next operation
    /// - Parameter error: The error to throw
    public func setShouldThrowError(_ error: TreasureMapRepositoryError?) {
        shouldThrowError = error
    }
    
    /// Resets all mock state and call counts
    public func reset() {
        mockMaps = []
        shouldThrowError = nil
        getAllMapsCallCount = 0
        getMapCallCount = 0
        mapExistsCallCount = 0
    }
    
    // MARK: - Call Count Tracking
    
    public var getAllMapsWasCalledCount: Int {
        return getAllMapsCallCount
    }
    
    public var getMapWasCalledCount: Int {
        return getMapCallCount
    }
    
    public var mapExistsWasCalledCount: Int {
        return mapExistsCallCount
    }
    
    // MARK: - TreasureMapRepository Implementation
    
    public func getAllMaps() async throws -> [TreasureMap] {
        getAllMapsCallCount += 1
        
        if let error = shouldThrowError {
            throw error
        }
        
        return mockMaps
    }
    
    public func getMap(by id: UUID) async throws -> TreasureMap? {
        getMapCallCount += 1
        
        if let error = shouldThrowError {
            throw error
        }
        
        return mockMaps.first { $0.id == id }
    }
    
    public func mapExists(id: UUID) async throws -> Bool {
        mapExistsCallCount += 1
        
        if let error = shouldThrowError {
            throw error
        }
        
        return mockMaps.contains { $0.id == id }
    }
}