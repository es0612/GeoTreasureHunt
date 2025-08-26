import Testing
import CoreLocation
@testable import GeoSonarCore
import GeoSonarTesting

@Suite("LocationService Integration Tests")
@MainActor
struct LocationServiceIntegrationTests {
    
    // MARK: - Test Data
    
    private let testLocation = CLLocation(
        latitude: 35.7148,
        longitude: 139.7753
    )
    
    // MARK: - Initialization Tests
    
    @Test("LocationService初期化")
    func testLocationServiceInitialization() async {
        let locationService = LocationService()
        
        // 初期状態の確認
        #expect(locationService.currentLocation == nil)
        #expect(locationService.isLocationUpdating == false)
        #expect(locationService.isGPSSignalWeak == false)
        // authorizationStatusは実際のシステム状態に依存するため、特定の値をテストしない
    }
    
    // MARK: - Protocol Conformance Tests
    
    @Test("LocationServiceProtocol準拠確認")
    func testLocationServiceProtocolConformance() async {
        let locationService: any LocationServiceProtocol = LocationService()
        
        // プロトコルのプロパティにアクセス可能であることを確認
        _ = locationService.currentLocation
        _ = locationService.authorizationStatus
        _ = locationService.isLocationUpdating
        _ = locationService.isGPSSignalWeak
        
        // プロトコルのメソッドが呼び出し可能であることを確認
        locationService.requestLocationPermission()
        locationService.stopLocationUpdates()
        
        // startLocationUpdatesは許可状態に依存するため、エラーハンドリングでテスト
        do {
            try locationService.startLocationUpdates()
            // 許可がある場合は成功
            locationService.stopLocationUpdates()
        } catch let error as LocationServiceError {
            // 許可がない場合はエラーが投げられることを確認
            #expect(error == .permissionDenied || error == .serviceUnavailable)
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Error Handling Tests
    
    @Test("エラーハンドリング - 位置情報サービス無効")
    func testLocationServicesDisabled() async {
        let locationService = LocationService()
        
        // 位置情報サービスが無効な場合のテスト
        // 実際のシステム状態に依存するため、モックでのテストが主となる
        // ここでは実装が正しくエラーを投げることを確認
        
        // 許可がない状態で開始を試行
        do {
            try locationService.startLocationUpdates()
            // 許可がある場合は停止
            locationService.stopLocationUpdates()
        } catch let error as LocationServiceError {
            // 期待されるエラーの確認
            #expect(error == .permissionDenied || error == .serviceUnavailable)
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Mock vs Real Implementation Compatibility Tests
    
    @Test("MockとRealの互換性確認")
    func testMockAndRealCompatibility() async {
        let mockService = MockLocationService()
        let realService = LocationService()
        
        // 両方のサービスが同じプロトコルに準拠していることを確認
        let services: [any LocationServiceProtocol] = [mockService, realService]
        
        for service in services {
            // 共通のプロパティアクセス
            _ = service.currentLocation
            _ = service.authorizationStatus
            _ = service.isLocationUpdating
            _ = service.isGPSSignalWeak
            
            // 共通のメソッド呼び出し
            service.requestLocationPermission()
            service.stopLocationUpdates()
        }
    }
    
    // MARK: - State Management Tests
    
    @Test("状態管理 - 位置更新の開始と停止")
    func testLocationUpdateStateManagement() async {
        let locationService = LocationService()
        
        // 初期状態確認
        #expect(locationService.isLocationUpdating == false)
        
        // 停止状態から停止を呼んでも問題ないことを確認
        locationService.stopLocationUpdates()
        #expect(locationService.isLocationUpdating == false)
        
        // 許可がない状態での開始試行
        do {
            try locationService.startLocationUpdates()
            // 成功した場合は停止
            #expect(locationService.isLocationUpdating == true)
            locationService.stopLocationUpdates()
            #expect(locationService.isLocationUpdating == false)
        } catch {
            // エラーが投げられた場合、状態は変更されないことを確認
            #expect(locationService.isLocationUpdating == false)
        }
    }
    
    // MARK: - Permission Request Tests
    
    @Test("許可要求の安全性")
    func testPermissionRequestSafety() async {
        let locationService = LocationService()
        
        // 複数回の許可要求が安全であることを確認
        locationService.requestLocationPermission()
        locationService.requestLocationPermission()
        locationService.requestLocationPermission()
        
        // クラッシュしないことを確認（実際の許可状態は変わらない可能性がある）
    }
    
    // MARK: - Memory Management Tests
    
    @Test("メモリ管理 - サービスの作成と破棄")
    func testMemoryManagement() async {
        // LocationServiceの作成と破棄が正常に行われることを確認
        var locationService: LocationService? = LocationService()
        
        // サービスを使用
        locationService?.requestLocationPermission()
        locationService?.stopLocationUpdates()
        
        // サービスを破棄
        locationService = nil
        
        // 新しいサービスを作成
        locationService = LocationService()
        #expect(locationService != nil)
        
        // 再度破棄
        locationService = nil
    }
    
    // MARK: - Thread Safety Tests
    
    @Test("スレッドセーフティ - MainActor確認")
    func testMainActorCompliance() async {
        // LocationServiceが@MainActorで実行されることを確認
        await MainActor.run {
            let locationService = LocationService()
            
            // MainActorコンテキストでの操作
            locationService.requestLocationPermission()
            locationService.stopLocationUpdates()
            
            // プロパティアクセス
            _ = locationService.currentLocation
            _ = locationService.authorizationStatus
            _ = locationService.isLocationUpdating
            _ = locationService.isGPSSignalWeak
        }
    }
    
    // MARK: - Configuration Tests
    
    @Test("設定値の確認")
    func testLocationServiceConfiguration() async {
        let locationService = LocationService()
        
        // LocationServiceが適切に設定されていることを確認
        // 内部の設定値は直接アクセスできないが、動作を通じて確認
        
        // 初期化後の状態確認
        #expect(locationService.isLocationUpdating == false)
        #expect(locationService.currentLocation == nil)
        
        // GPS信号品質の初期状態
        #expect(locationService.isGPSSignalWeak == false)
    }
}