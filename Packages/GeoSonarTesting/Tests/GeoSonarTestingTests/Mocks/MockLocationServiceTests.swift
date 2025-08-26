import Testing
import CoreLocation
@testable import GeoSonarTesting
import GeoSonarCore

@Suite("MockLocationService Tests")
@MainActor
struct MockLocationServiceTests {
    
    // MARK: - Test Data
    
    private let testLocation = CLLocation(
        latitude: 35.7148,
        longitude: 139.7753
    )
    
    // MARK: - Basic Functionality Tests
    
    @Test("MockLocationService初期化")
    func testMockLocationServiceInitialization() async {
        let mockService = MockLocationService()
        
        // 初期状態の確認
        #expect(mockService.currentLocation == nil)
        #expect(mockService.authorizationStatus == .notDetermined)
        #expect(mockService.isLocationUpdating == false)
        #expect(mockService.isGPSSignalWeak == false)
        #expect(mockService.shouldThrowOnStartUpdates == false)
        #expect(mockService.errorToThrow == nil)
    }
    
    @Test("位置情報シミュレーション")
    func testLocationSimulation() async {
        let mockService = MockLocationService()
        
        // 位置情報更新をシミュレート
        mockService.simulateLocationUpdate(testLocation)
        
        // 結果確認
        #expect(mockService.currentLocation != nil)
        #expect(mockService.currentLocation?.coordinate.latitude == testLocation.coordinate.latitude)
        #expect(mockService.currentLocation?.coordinate.longitude == testLocation.coordinate.longitude)
    }
    
    @Test("認証状態シミュレーション")
    func testAuthorizationSimulation() async {
        let mockService = MockLocationService()
        
        // 各認証状態をテスト
        #if os(iOS)
        let statuses: [CLAuthorizationStatus] = [
            .notDetermined,
            .denied,
            .restricted,
            .authorizedWhenInUse,
            .authorizedAlways
        ]
        #else
        let statuses: [CLAuthorizationStatus] = [
            .notDetermined,
            .denied,
            .restricted,
            .authorizedAlways
        ]
        #endif
        
        for status in statuses {
            mockService.simulateAuthorizationChange(status)
            #expect(mockService.authorizationStatus == status)
        }
    }
    
    // MARK: - Callback Tests
    
    @Test("許可要求コールバック")
    func testPermissionRequestCallback() async {
        let mockService = MockLocationService()
        
        var callbackExecuted = false
        mockService.permissionRequestCallback = {
            callbackExecuted = true
        }
        
        mockService.requestLocationPermission()
        
        #expect(callbackExecuted == true)
        #if os(iOS)
        #expect(mockService.authorizationStatus == .authorizedWhenInUse)
        #else
        #expect(mockService.authorizationStatus == .authorizedAlways)
        #endif
    }
    
    @Test("位置更新開始コールバック")
    func testStartUpdatesCallback() async throws {
        let mockService = MockLocationService()
        #if os(iOS)
        mockService.simulateAuthorizationChange(.authorizedWhenInUse)
        #else
        mockService.simulateAuthorizationChange(.authorizedAlways)
        #endif
        
        var callbackExecuted = false
        mockService.startUpdatesCallback = {
            callbackExecuted = true
        }
        
        try mockService.startLocationUpdates()
        
        #expect(callbackExecuted == true)
        #expect(mockService.isLocationUpdating == true)
    }
    
    @Test("位置更新停止コールバック")
    func testStopUpdatesCallback() async throws {
        let mockService = MockLocationService()
        #if os(iOS)
        mockService.simulateAuthorizationChange(.authorizedWhenInUse)
        #else
        mockService.simulateAuthorizationChange(.authorizedAlways)
        #endif
        try mockService.startLocationUpdates()
        
        var callbackExecuted = false
        mockService.stopUpdatesCallback = {
            callbackExecuted = true
        }
        
        mockService.stopLocationUpdates()
        
        #expect(callbackExecuted == true)
        #expect(mockService.isLocationUpdating == false)
    }
    
    // MARK: - Error Simulation Tests
    
    @Test("エラーシミュレーション - 許可拒否")
    func testPermissionDeniedError() async {
        let mockService = MockLocationService()
        mockService.simulateAuthorizationChange(.denied)
        
        do {
            try mockService.startLocationUpdates()
            Issue.record("Expected LocationServiceError.permissionDenied to be thrown")
        } catch let error as LocationServiceError {
            #expect(error == .permissionDenied)
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
    
    @Test("エラーシミュレーション - カスタムエラー")
    func testCustomErrorSimulation() async {
        let mockService = MockLocationService()
        #if os(iOS)
        mockService.simulateAuthorizationChange(.authorizedWhenInUse)
        #else
        mockService.simulateAuthorizationChange(.authorizedAlways)
        #endif
        mockService.shouldThrowOnStartUpdates = true
        mockService.errorToThrow = .serviceUnavailable
        
        do {
            try mockService.startLocationUpdates()
            Issue.record("Expected LocationServiceError.serviceUnavailable to be thrown")
        } catch let error as LocationServiceError {
            #expect(error == .serviceUnavailable)
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - GPS Signal Quality Tests
    
    @Test("GPS信号品質の自動検出")
    func testAutomaticGPSSignalDetection() async {
        let mockService = MockLocationService()
        
        // 良好な精度の位置情報
        let goodLocation = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753),
            altitude: 0,
            horizontalAccuracy: 5.0,
            verticalAccuracy: 0,
            timestamp: Date()
        )
        
        mockService.simulateLocationUpdate(goodLocation)
        #expect(mockService.isGPSSignalWeak == false)
        
        // 悪い精度の位置情報
        let poorLocation = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753),
            altitude: 0,
            horizontalAccuracy: 100.0,
            verticalAccuracy: 0,
            timestamp: Date()
        )
        
        mockService.simulateLocationUpdate(poorLocation)
        #expect(mockService.isGPSSignalWeak == true)
    }
    
    @Test("GPS信号品質の手動制御")
    func testManualGPSSignalControl() async {
        let mockService = MockLocationService()
        
        // 初期状態
        #expect(mockService.isGPSSignalWeak == false)
        
        // 弱い信号に設定
        mockService.simulateWeakGPSSignal(true)
        #expect(mockService.isGPSSignalWeak == true)
        
        // 強い信号に戻す
        mockService.simulateWeakGPSSignal(false)
        #expect(mockService.isGPSSignalWeak == false)
    }
    
    // MARK: - Reset Functionality Tests
    
    @Test("完全リセット機能")
    func testCompleteReset() async throws {
        let mockService = MockLocationService()
        
        // 全ての状態を変更
        #if os(iOS)
        mockService.simulateAuthorizationChange(.authorizedWhenInUse)
        #else
        mockService.simulateAuthorizationChange(.authorizedAlways)
        #endif
        try mockService.startLocationUpdates()
        mockService.simulateLocationUpdate(testLocation)
        mockService.simulateWeakGPSSignal(true)
        mockService.shouldThrowOnStartUpdates = true
        mockService.errorToThrow = .serviceUnavailable
        
        // コールバックも設定
        mockService.permissionRequestCallback = { }
        mockService.startUpdatesCallback = { }
        mockService.stopUpdatesCallback = { }
        
        // リセット実行
        mockService.reset()
        
        // 全ての状態が初期値に戻ったことを確認
        #expect(mockService.currentLocation == nil)
        #expect(mockService.authorizationStatus == .notDetermined)
        #expect(mockService.isLocationUpdating == false)
        #expect(mockService.isGPSSignalWeak == false)
        #expect(mockService.shouldThrowOnStartUpdates == false)
        #expect(mockService.errorToThrow == nil)
        #expect(mockService.permissionRequestCallback == nil)
        #expect(mockService.startUpdatesCallback == nil)
        #expect(mockService.stopUpdatesCallback == nil)
    }
    
    // MARK: - Protocol Conformance Tests
    
    @Test("LocationServiceProtocol準拠確認")
    func testProtocolConformance() async {
        let mockService: any LocationServiceProtocol = MockLocationService()
        
        // プロトコルのプロパティにアクセス可能であることを確認
        _ = mockService.currentLocation
        _ = mockService.authorizationStatus
        _ = mockService.isLocationUpdating
        _ = mockService.isGPSSignalWeak
        
        // プロトコルのメソッドが呼び出し可能であることを確認
        mockService.requestLocationPermission()
        mockService.stopLocationUpdates()
        
        // startLocationUpdatesは例外を投げる可能性があるため別途テスト
        do {
            try mockService.startLocationUpdates()
        } catch {
            // エラーが投げられても問題なし（許可がない場合など）
        }
    }
}