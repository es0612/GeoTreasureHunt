import Testing
import CoreLocation
@testable import GeoSonarCore
import GeoSonarTesting

@Suite("LocationService Tests")
@MainActor
struct LocationServiceTests {
    
    // MARK: - Test Data
    
    private let testLocation = CLLocation(
        latitude: 35.7148,
        longitude: 139.7753
    )
    
    private let weakAccuracyLocation = CLLocation(
        coordinate: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753),
        altitude: 0,
        horizontalAccuracy: 100.0, // Poor accuracy
        verticalAccuracy: 0,
        timestamp: Date()
    )
    
    // MARK: - Permission Request Tests
    
    @Test("位置情報許可要求 - 初期状態から許可まで")
    func testLocationPermissionRequest() async {
        let mockService = MockLocationService()
        
        // 初期状態の確認
        #expect(mockService.authorizationStatus == .notDetermined)
        
        // 許可要求のコールバック設定
        var permissionRequested = false
        mockService.permissionRequestCallback = {
            permissionRequested = true
        }
        
        // 許可要求実行
        mockService.requestLocationPermission()
        
        // 結果確認
        #expect(permissionRequested == true)
        #if os(iOS)
        #expect(mockService.authorizationStatus == .authorizedWhenInUse)
        #else
        #expect(mockService.authorizationStatus == .authorizedAlways)
        #endif
    }
    
    @Test("位置情報許可要求 - 拒否された場合")
    func testLocationPermissionDenied() async {
        let mockService = MockLocationService()
        
        // 許可拒否をシミュレート
        mockService.simulateAuthorizationChange(.denied)
        
        // 位置更新開始を試行
        do {
            try mockService.startLocationUpdates()
            Issue.record("Expected LocationServiceError.permissionDenied to be thrown")
        } catch let error as LocationServiceError {
            #expect(error == .permissionDenied)
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Location Updates Tests
    
    @Test("リアルタイム位置更新 - 正常開始")
    func testStartLocationUpdates() async throws {
        let mockService = MockLocationService()
        
        // 許可状態に設定
        #if os(iOS)
        mockService.simulateAuthorizationChange(.authorizedWhenInUse)
        #else
        mockService.simulateAuthorizationChange(.authorizedAlways)
        #endif
        
        // 開始コールバック設定
        var updatesStarted = false
        mockService.startUpdatesCallback = {
            updatesStarted = true
        }
        
        // 位置更新開始
        try mockService.startLocationUpdates()
        
        // 結果確認
        #expect(mockService.isLocationUpdating == true)
        #expect(updatesStarted == true)
    }
    
    @Test("リアルタイム位置更新 - 許可なしでエラー")
    func testStartLocationUpdatesWithoutPermission() async {
        let mockService = MockLocationService()
        
        // 許可なし状態
        mockService.simulateAuthorizationChange(.notDetermined)
        
        // 位置更新開始を試行
        do {
            try mockService.startLocationUpdates()
            Issue.record("Expected LocationServiceError.permissionDenied to be thrown")
        } catch let error as LocationServiceError {
            #expect(error == .permissionDenied)
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
        
        #expect(mockService.isLocationUpdating == false)
    }
    
    @Test("位置更新停止")
    func testStopLocationUpdates() async throws {
        let mockService = MockLocationService()
        
        // 許可状態に設定して開始
        #if os(iOS)
        mockService.simulateAuthorizationChange(.authorizedWhenInUse)
        #else
        mockService.simulateAuthorizationChange(.authorizedAlways)
        #endif
        try mockService.startLocationUpdates()
        
        // 停止コールバック設定
        var updatesStopped = false
        mockService.stopUpdatesCallback = {
            updatesStopped = true
        }
        
        // 位置更新停止
        mockService.stopLocationUpdates()
        
        // 結果確認
        #expect(mockService.isLocationUpdating == false)
        #expect(updatesStopped == true)
    }
    
    @Test("位置情報受信と更新")
    func testLocationUpdate() async {
        let mockService = MockLocationService()
        
        // 初期状態確認
        #expect(mockService.currentLocation == nil)
        
        // 位置情報更新をシミュレート
        mockService.simulateLocationUpdate(testLocation)
        
        // 結果確認
        #expect(mockService.currentLocation != nil)
        #expect(mockService.currentLocation?.coordinate.latitude == testLocation.coordinate.latitude)
        #expect(mockService.currentLocation?.coordinate.longitude == testLocation.coordinate.longitude)
    }
    
    // MARK: - GPS Signal Quality Tests
    
    @Test("GPS信号品質 - 良好な信号")
    func testGoodGPSSignal() async {
        let mockService = MockLocationService()
        
        let goodAccuracyLocation = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753),
            altitude: 0,
            horizontalAccuracy: 5.0, // Good accuracy
            verticalAccuracy: 0,
            timestamp: Date()
        )
        
        // 良好な精度の位置情報を設定
        mockService.simulateLocationUpdate(goodAccuracyLocation)
        
        // GPS信号が良好であることを確認
        #expect(mockService.isGPSSignalWeak == false)
    }
    
    @Test("GPS信号品質 - 弱い信号")
    func testWeakGPSSignal() async {
        let mockService = MockLocationService()
        
        // 弱い精度の位置情報を設定
        mockService.simulateLocationUpdate(weakAccuracyLocation)
        
        // GPS信号が弱いことを確認
        #expect(mockService.isGPSSignalWeak == true)
    }
    
    @Test("GPS信号品質 - 手動シミュレート")
    func testManualGPSSignalSimulation() async {
        let mockService = MockLocationService()
        
        // 初期状態確認
        #expect(mockService.isGPSSignalWeak == false)
        
        // 弱い信号をシミュレート
        mockService.simulateWeakGPSSignal(true)
        #expect(mockService.isGPSSignalWeak == true)
        
        // 信号回復をシミュレート
        mockService.simulateWeakGPSSignal(false)
        #expect(mockService.isGPSSignalWeak == false)
    }
    
    // MARK: - Background Processing Tests
    
    @Test("バックグラウンド処理 - 位置更新停止")
    func testBackgroundLocationHandling() async throws {
        let mockService = MockLocationService()
        
        // 位置更新を開始
        #if os(iOS)
        mockService.simulateAuthorizationChange(.authorizedWhenInUse)
        #else
        mockService.simulateAuthorizationChange(.authorizedAlways)
        #endif
        try mockService.startLocationUpdates()
        #expect(mockService.isLocationUpdating == true)
        
        // バックグラウンド移行をシミュレート（位置更新停止）
        mockService.stopLocationUpdates()
        
        // バックグラウンドでは位置更新が停止されることを確認
        #expect(mockService.isLocationUpdating == false)
    }
    
    // MARK: - Error Handling Tests
    
    @Test("エラーハンドリング - サービス利用不可")
    func testServiceUnavailableError() async {
        let mockService = MockLocationService()
        
        // エラーを設定
        mockService.shouldThrowOnStartUpdates = true
        mockService.errorToThrow = .serviceUnavailable
        #if os(iOS)
        mockService.simulateAuthorizationChange(.authorizedWhenInUse)
        #else
        mockService.simulateAuthorizationChange(.authorizedAlways)
        #endif
        
        // エラーが投げられることを確認
        do {
            try mockService.startLocationUpdates()
            Issue.record("Expected LocationServiceError.serviceUnavailable to be thrown")
        } catch let error as LocationServiceError {
            #expect(error == .serviceUnavailable)
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
    
    @Test("エラーハンドリング - 位置更新失敗")
    func testLocationUpdateFailedError() async {
        let mockService = MockLocationService()
        
        // エラーを設定
        mockService.shouldThrowOnStartUpdates = true
        mockService.errorToThrow = .locationUpdateFailed
        #if os(iOS)
        mockService.simulateAuthorizationChange(.authorizedWhenInUse)
        #else
        mockService.simulateAuthorizationChange(.authorizedAlways)
        #endif
        
        // エラーが投げられることを確認
        do {
            try mockService.startLocationUpdates()
            Issue.record("Expected LocationServiceError.locationUpdateFailed to be thrown")
        } catch let error as LocationServiceError {
            #expect(error == .locationUpdateFailed)
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Mock Reset Tests
    
    @Test("モック状態リセット")
    func testMockReset() async throws {
        let mockService = MockLocationService()
        
        // 状態を変更
        #if os(iOS)
        mockService.simulateAuthorizationChange(.authorizedWhenInUse)
        #else
        mockService.simulateAuthorizationChange(.authorizedAlways)
        #endif
        try mockService.startLocationUpdates()
        mockService.simulateLocationUpdate(testLocation)
        mockService.simulateWeakGPSSignal(true)
        
        // 変更された状態を確認
        #if os(iOS)
        #expect(mockService.authorizationStatus == .authorizedWhenInUse)
        #else
        #expect(mockService.authorizationStatus == .authorizedAlways)
        #endif
        #expect(mockService.isLocationUpdating == true)
        #expect(mockService.currentLocation != nil)
        #expect(mockService.isGPSSignalWeak == true)
        
        // リセット実行
        mockService.reset()
        
        // 初期状態に戻ったことを確認
        #expect(mockService.authorizationStatus == .notDetermined)
        #expect(mockService.isLocationUpdating == false)
        #expect(mockService.currentLocation == nil)
        #expect(mockService.isGPSSignalWeak == false)
    }
}