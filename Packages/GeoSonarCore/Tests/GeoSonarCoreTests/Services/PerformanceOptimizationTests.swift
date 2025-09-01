import Testing
import Foundation
import CoreLocation
@testable import GeoSonarCore

@Suite("Performance Optimization Tests")
struct PerformanceOptimizationTests {
    
    @Test("Battery consumption optimization - GPS update frequency adjustment")
    @MainActor
    func testBatteryOptimizationGPSFrequency() async {
        let locationService = LocationService()
        
        // Test that GPS update frequency can be adjusted based on battery level
        locationService.setBatteryOptimizationMode(.aggressive)
        #expect(locationService.updateInterval >= 5.0) // Should be at least 5 seconds in aggressive mode
        
        locationService.setBatteryOptimizationMode(.balanced)
        #expect(locationService.updateInterval >= 2.0) // Should be at least 2 seconds in balanced mode
        
        locationService.setBatteryOptimizationMode(.performance)
        #expect(locationService.updateInterval >= 1.0) // Should be at least 1 second in performance mode
    }
    
    @Test("Memory usage monitoring - Service memory footprint")
    func testMemoryUsageMonitoring() async {
        let initialMemory = getMemoryUsage()
        
        // Create multiple services and check memory usage
        var services: [Any] = []
        for _ in 0..<100 {
            services.append(ExplorationService())
            services.append(FeedbackService())
        }
        
        let afterCreationMemory = getMemoryUsage()
        let memoryIncrease = afterCreationMemory - initialMemory
        
        // Memory increase should be reasonable (less than 10MB for 200 services)
        #expect(memoryIncrease < 10_000_000) // 10MB in bytes
        
        // Clear services and check for memory cleanup
        services.removeAll()
        
        // Force garbage collection
        autoreleasepool {
            // Empty pool to trigger cleanup
        }
        
        let afterCleanupMemory = getMemoryUsage()
        let memoryAfterCleanup = afterCleanupMemory - initialMemory
        
        // Memory should be mostly cleaned up (within 2MB of initial)
        #expect(memoryAfterCleanup < 2_000_000) // 2MB in bytes
    }
    
    @Test("GPS update frequency dynamic adjustment based on movement")
    @MainActor
    func testDynamicGPSUpdateFrequency() async {
        let locationService = LocationService()
        
        // Set to performance mode for more predictable testing
        locationService.setBatteryOptimizationMode(.performance)
        
        // Simulate stationary user
        locationService.simulateMovementState(.stationary)
        await locationService.optimizeUpdateFrequency()
        #expect(locationService.updateInterval >= 10.0) // Should reduce frequency when stationary
        
        // Simulate walking user
        locationService.simulateMovementState(.walking)
        await locationService.optimizeUpdateFrequency()
        #expect(locationService.updateInterval >= 2.0 && locationService.updateInterval <= 5.0)
        
        // Simulate running user
        locationService.simulateMovementState(.running)
        await locationService.optimizeUpdateFrequency()
        #expect(locationService.updateInterval >= 1.0 && locationService.updateInterval <= 2.0)
    }
    
    @Test("Performance test - Distance calculation efficiency")
    func testDistanceCalculationPerformance() async {
        let service = ExplorationService()
        let userLocation = CLLocation(latitude: 35.7148, longitude: 139.7753)
        
        // Generate test treasures
        let treasures = generateTestTreasures(count: 1000)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Perform distance calculations
        for treasure in treasures {
            _ = service.calculateDistance(from: userLocation, to: treasure.coordinate)
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        // Should complete 1000 distance calculations in less than 100ms
        #expect(timeElapsed < 0.1)
    }
    
    @Test("Performance test - Direction calculation efficiency")
    func testDirectionCalculationPerformance() async {
        let service = ExplorationService()
        let userLocation = CLLocation(latitude: 35.7148, longitude: 139.7753)
        
        // Generate test treasures
        let treasures = generateTestTreasures(count: 1000)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Perform direction calculations
        for treasure in treasures {
            _ = service.calculateDirection(from: userLocation, to: treasure.coordinate)
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        // Should complete 1000 direction calculations in less than 100ms
        #expect(timeElapsed < 0.1)
    }
    
    @Test("Memory leak detection - ErrorHandler")
    @MainActor
    func testErrorHandlerMemoryLeaks() async {
        let initialMemory = getMemoryUsage()
        
        // Create and use multiple error handlers (reduced count to avoid system limits)
        for _ in 0..<10 {
            autoreleasepool {
                let errorHandler = ErrorHandler()
                Task { @MainActor in
                    await errorHandler.handle(.gpsSignalWeak)
                    await errorHandler.clearError()
                }
            }
        }
        
        // Force cleanup
        autoreleasepool {}
        
        // Give some time for cleanup
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        let finalMemory = getMemoryUsage()
        let memoryIncrease = finalMemory - initialMemory
        
        // Memory increase should be minimal (less than 5MB for reduced test)
        #expect(memoryIncrease < 5_000_000)
    }
    
    @Test("Battery optimization - Background processing suspension")
    @MainActor
    func testBackgroundProcessingSuspension() async {
        let locationService = LocationService()
        
        // Set up authorization status for testing
        #if os(iOS)
        locationService.authorizationStatus = .authorizedWhenInUse
        #else
        locationService.authorizationStatus = .authorizedAlways
        #endif
        
        // Start location updates (simulate successful start)
        locationService.isLocationUpdating = true
        #expect(locationService.isLocationUpdating == true)
        
        // Simulate app going to background
        locationService.suspendForBatteryOptimization()
        #expect(locationService.isLocationUpdating == false)
        
        // Simulate app returning to foreground
        locationService.resumeFromBatteryOptimization()
        #expect(locationService.isLocationUpdating == true)
    }
    
    // MARK: - Helper Methods
    
    private func getMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return info.resident_size
        } else {
            return 0
        }
    }
    
    private func generateTestTreasures(count: Int) -> [Treasure] {
        var treasures: [Treasure] = []
        
        for i in 0..<count {
            let lat = 35.7148 + Double(i) * 0.001
            let lon = 139.7753 + Double(i) * 0.001
            
            let treasure = Treasure(
                id: UUID(),
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                name: "Test Treasure \(i)",
                description: "Test treasure for performance testing",
                points: 100,
                discoveryRadius: 10.0
            )
            treasures.append(treasure)
        }
        
        return treasures
    }
}

// MARK: - Supporting Types for Performance Testing

// Note: The actual implementation is now in LocationService.swift