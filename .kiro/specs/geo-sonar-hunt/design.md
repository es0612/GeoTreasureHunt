# 設計ドキュメント

## 概要

Geo Sonar Huntは、最新のSwift 6、SwiftUI、XcodeGen、Swift Package Manager（SPM）を使用して構築されるiOS向けGPSベースの宝探しゲームです。プロジェクトはTDD（テスト駆動開発）アプローチを採用し、ローカルパッケージによるモジュラー設計により高速なテスト実行とコードの再利用性を実現します。アプリは完全にオフラインで動作し、ローカルデータを使用してリアルタイムの位置追跡、方向案内、距離フィードバックを提供します。

## アーキテクチャ

### アーキテクチャパターン: MVVM + Repository + TDD

アプリケーションは以下の理由でMVVM（Model-View-ViewModel）パターンとTDDアプローチを採用します：

- **SwiftUIとの自然な統合**: SwiftUIの宣言的UIとリアクティブデータバインディングに最適
- **テスト駆動開発**: Red-Green-Refactorサイクルによる高品質なコード
- **Swift 6の活用**: 厳格な並行性チェック、@Observable、Swift Testingフレームワーク
- **モジュラー設計**: SPMローカルパッケージによる高速テスト実行
- **XcodeGen**: プロジェクト設定の自動化と一貫性の確保

### プロジェクト構造とモジュール設計

```
GeoSonarHunt/
├── project.yml                    # XcodeGen設定
├── GeoSonarHuntApp/               # メインアプリターゲット
│   ├── App.swift
│   ├── Views/
│   └── Resources/
├── Packages/                      # ローカルSPMパッケージ
│   ├── GeoSonarCore/             # コアビジネスロジック
│   │   ├── Sources/
│   │   │   ├── Models/
│   │   │   ├── Services/
│   │   │   └── Repositories/
│   │   └── Tests/
│   ├── GeoSonarUI/               # UI コンポーネント
│   │   ├── Sources/
│   │   │   ├── ViewModels/
│   │   │   └── Views/
│   │   └── Tests/
│   └── GeoSonarTesting/          # テストユーティリティ
│       ├── Sources/
│       │   ├── Mocks/
│       │   └── TestHelpers/
│       └── Tests/
└── Tests/                        # 統合テスト
    ├── GeoSonarHuntTests/
    └── GeoSonarHuntUITests/
```

### レイヤー構造

```
┌─────────────────────────────────────┐
│         GeoSonarHuntApp             │  ← メインアプリ
├─────────────────────────────────────┤
│           GeoSonarUI                │  ← UI層（ViewModels + Views）
├─────────────────────────────────────┤
│          GeoSonarCore               │  ← ビジネスロジック層
│  ┌─────────────────────────────────┐ │
│  │           Services              │ │
│  ├─────────────────────────────────┤ │
│  │         Repositories            │ │
│  ├─────────────────────────────────┤ │
│  │       Models & Entities         │ │
│  └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

## コンポーネントとインターフェース

### 1. データモデル

#### TreasureMap
```swift
struct TreasureMap: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let region: MapRegion
    let treasures: [Treasure]
    let difficulty: Difficulty
}
```

#### Treasure
```swift
struct Treasure: Identifiable, Codable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let name: String
    let description: String
    let points: Int
    let discoveryRadius: Double // メートル単位
}
```

#### GameSession
```swift
struct GameSession: Identifiable {
    let id: UUID
    let mapId: UUID
    let startTime: Date
    var discoveredTreasures: Set<UUID>
    var totalPoints: Int
    var isActive: Bool
}
```

#### ExplorationMode
```swift
enum ExplorationMode: CaseIterable {
    case dowsing    // ダウジング（方向案内）
    case sonar      // ソナー（距離フィードバック）
}
```

### 2. Repository層

#### TreasureMapRepository
```swift
protocol TreasureMapRepository {
    func getAllMaps() async -> [TreasureMap]
    func getMap(by id: UUID) async -> TreasureMap?
}

class LocalTreasureMapRepository: TreasureMapRepository {
    // JSONファイルまたはハードコードされたデータからマップを読み込み
}
```

#### GameProgressRepository
```swift
protocol GameProgressRepository {
    func saveProgress(_ session: GameSession) async
    func loadProgress(for mapId: UUID) async -> GameSession?
    func getDiscoveredTreasures(for mapId: UUID) async -> Set<UUID>
}

class LocalGameProgressRepository: GameProgressRepository {
    // UserDefaultsまたはCore Dataを使用してローカル保存
}
```

### 3. Service層

#### LocationService
```swift
@Observable
class LocationService: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var isLocationUpdating: Bool = false
    
    func requestLocationPermission()
    func startLocationUpdates()
    func stopLocationUpdates()
}
```

#### ExplorationService
```swift
@Observable
class ExplorationService {
    func calculateDirection(from: CLLocation, to: CLLocationCoordinate2D) -> Double
    func calculateDistance(from: CLLocation, to: CLLocationCoordinate2D) -> Double
    func checkTreasureDiscovery(userLocation: CLLocation, treasures: [Treasure]) -> Treasure?
}
```

#### FeedbackService
```swift
class FeedbackService {
    func provideSonarFeedback(distance: Double, settings: GameSettings)
    func provideHapticFeedback(intensity: HapticIntensity)
    func playAudioFeedback(type: AudioFeedbackType, volume: Float)
}
```

### 4. ViewModel層

#### MapSelectionViewModel
```swift
@Observable
class MapSelectionViewModel {
    private let treasureMapRepository: TreasureMapRepository
    private let progressRepository: GameProgressRepository
    
    var availableMaps: [TreasureMap] = []
    var isLoading: Bool = false
    
    func loadMaps() async
    func selectMap(_ map: TreasureMap) -> GameSession
}
```

#### ExplorationViewModel
```swift
@Observable
class ExplorationViewModel {
    private let locationService: LocationService
    private let explorationService: ExplorationService
    private let feedbackService: FeedbackService
    private let progressRepository: GameProgressRepository
    
    var currentSession: GameSession
    var currentMode: ExplorationMode = .dowsing
    var nearestTreasure: Treasure?
    var directionToTreasure: Double = 0
    var distanceToTreasure: Double = 0
    
    func switchMode(to mode: ExplorationMode)
    func sendSonarPing()
    func checkForTreasureDiscovery()
}
```

### 5. View層

#### MapSelectionView
```swift
struct MapSelectionView: View {
    @State private var viewModel: MapSelectionViewModel
    
    var body: some View {
        NavigationStack {
            List(viewModel.availableMaps) { map in
                MapRowView(map: map) {
                    // 探索画面への遷移
                }
            }
        }
    }
}
```

#### ExplorationView
```swift
struct ExplorationView: View {
    @State private var viewModel: ExplorationViewModel
    
    var body: some View {
        ZStack {
            MapView(session: viewModel.currentSession)
            
            VStack {
                ModeToggleView(currentMode: viewModel.currentMode) { mode in
                    viewModel.switchMode(to: mode)
                }
                
                Spacer()
                
                switch viewModel.currentMode {
                case .dowsing:
                    DowsingCompassView(direction: viewModel.directionToTreasure)
                case .sonar:
                    SonarControlView {
                        viewModel.sendSonarPing()
                    }
                }
            }
        }
    }
}
```

## データモデル

### ローカルデータ構造

#### 宝の地図データ (JSON)
```json
{
  "maps": [
    {
      "id": "tokyo-parks-1",
      "name": "東京公園エリア",
      "description": "上野公園周辺の宝探し",
      "region": {
        "center": {
          "latitude": 35.7148,
          "longitude": 139.7753
        },
        "span": {
          "latitudeDelta": 0.01,
          "longitudeDelta": 0.01
        }
      },
      "treasures": [
        {
          "id": "treasure-1",
          "coordinate": {
            "latitude": 35.7158,
            "longitude": 139.7763
          },
          "name": "桜の宝",
          "description": "美しい桜の木の下に隠された宝",
          "points": 100,
          "discoveryRadius": 10.0
        }
      ],
      "difficulty": "easy"
    }
  ]
}
```

#### ユーザー進捗データ (UserDefaults)
```swift
struct UserProgress: Codable {
    let discoveredTreasures: [String: Set<String>] // mapId: treasureIds
    let totalPoints: Int
    let completedMaps: Set<String>
    let settings: GameSettings
}
```

### 最新技術の採用

#### Swift 6の活用
- **厳格な並行性チェック**: デフォルトで有効化されたデータ競合の検出
- **@Observable マクロ**: SwiftUIとの統合によるリアクティブな状態管理
- **Swift Testing**: 新しいテストフレームワークによる表現力豊かなテスト
- **typed throws**: より安全で予測可能なエラーハンドリング

#### XcodeGenによるプロジェクト管理
```yaml
# project.yml
name: GeoSonarHunt
options:
  bundleIdPrefix: com.geosohunt
  deploymentTarget:
    iOS: "15.0"
  
targets:
  GeoSonarHuntApp:
    type: application
    platform: iOS
    sources: [GeoSonarHuntApp]
    dependencies:
      - package: GeoSonarCore
      - package: GeoSonarUI
    
packages:
  GeoSonarCore:
    path: Packages/GeoSonarCore
  GeoSonarUI:
    path: Packages/GeoSonarUI
```

#### 状態管理（Swift 6 @Observable）

```swift
@Observable
class GameState {
    var currentSession: GameSession?
    var isLocationPermissionGranted: Bool = false
    var isFirstLaunch: Bool = true
    var settings: GameSettings = GameSettings()
    
    // Swift 6の厳格な並行性チェックに対応
    @MainActor
    func updateLocationPermission(_ granted: Bool) {
        isLocationPermissionGranted = granted
    }
}
```

## エラーハンドリング

### エラータイプ定義

```swift
enum GameError: LocalizedError {
    case locationPermissionDenied
    case locationServiceUnavailable
    case mapDataCorrupted
    case treasureDataMissing
    case gpsSignalWeak
    
    var errorDescription: String? {
        switch self {
        case .locationPermissionDenied:
            return "位置情報の許可が必要です"
        case .locationServiceUnavailable:
            return "位置情報サービスが利用できません"
        case .mapDataCorrupted:
            return "マップデータが破損しています"
        case .treasureDataMissing:
            return "宝のデータが見つかりません"
        case .gpsSignalWeak:
            return "GPS信号が弱いです。屋外に移動してください"
        }
    }
}
```

### エラー処理戦略

1. **優雅な劣化**: 重要でない機能の失敗時も基本機能は継続
2. **ユーザーフレンドリーなメッセージ**: 技術的詳細を隠した分かりやすいエラーメッセージ
3. **自動復旧**: 可能な場合は自動的にエラー状態から回復
4. **フォールバック**: 代替手段の提供（例：GPS不良時の手動位置設定）

### エラーハンドリング実装

```swift
@Observable
class ErrorHandler {
    var currentError: GameError?
    var isShowingError: Bool = false
    
    func handle(_ error: GameError) {
        currentError = error
        isShowingError = true
        
        // ログ記録（将来の分析用）
        logError(error)
        
        // 自動復旧の試行
        attemptRecovery(for: error)
    }
    
    private func attemptRecovery(for error: GameError) {
        switch error {
        case .gpsSignalWeak:
            // GPS精度向上の試行
            break
        case .mapDataCorrupted:
            // デフォルトマップの読み込み
            break
        default:
            break
        }
    }
}
```

## TDD（テスト駆動開発）戦略

### TDDサイクルの実装

#### Red-Green-Refactorサイクル
1. **Red**: 失敗するテストを書く
2. **Green**: テストを通す最小限のコードを書く
3. **Refactor**: コードを改善する

### Swift Testingフレームワークの活用

#### 基本テスト構造
```swift
import Testing
import GeoSonarCore

@Suite("宝探しコアロジック")
struct TreasureHuntCoreTests {
    
    @Test("距離計算の精度", arguments: [
        (35.7148, 139.7753, 35.7158, 139.7763, 111.0),
        (35.7148, 139.7753, 35.7148, 139.7753, 0.0)
    ])
    func testDistanceCalculation(
        userLat: Double, userLon: Double,
        treasureLat: Double, treasureLon: Double,
        expectedDistance: Double
    ) async throws {
        let service = ExplorationService()
        let userLocation = CLLocation(latitude: userLat, longitude: userLon)
        let treasureCoordinate = CLLocationCoordinate2D(
            latitude: treasureLat, 
            longitude: treasureLon
        )
        
        let distance = service.calculateDistance(
            from: userLocation, 
            to: treasureCoordinate
        )
        
        #expect(abs(distance - expectedDistance) < 10.0)
    }
}
```

#### ViewModelのTDDテスト
```swift
@Suite("探索ViewModel")
struct ExplorationViewModelTests {
    
    @Test("宝発見時のポイント計算")
    func testTreasureDiscoveryPoints() async throws {
        // Arrange
        let mockRepository = MockGameProgressRepository()
        let mockLocationService = MockLocationService()
        let viewModel = ExplorationViewModel(
            locationService: mockLocationService,
            explorationService: ExplorationService(),
            feedbackService: MockFeedbackService(),
            progressRepository: mockRepository
        )
        
        // Act
        let treasure = Treasure(
            id: UUID(),
            coordinate: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7753),
            name: "テスト宝",
            description: "テスト用の宝",
            points: 100,
            discoveryRadius: 10.0
        )
        
        await viewModel.discoverTreasure(treasure)
        
        // Assert
        #expect(viewModel.currentSession.totalPoints == 100)
        #expect(viewModel.currentSession.discoveredTreasures.contains(treasure.id))
    }
}
```

### モックとテストダブル

#### GeoSonarTestingパッケージ
```swift
// MockLocationService.swift
public class MockLocationService: LocationServiceProtocol {
    public var mockLocation: CLLocation?
    public var mockAuthorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse
    
    public func requestLocationPermission() {
        // テスト用の実装
    }
    
    public func startLocationUpdates() {
        // テスト用の実装
    }
}
```

### 高速テスト実行の実現

#### SPMローカルパッケージによる分離
```bash
# コアロジックのテストのみ実行（シミュレータ不要）
swift test --package-path Packages/GeoSonarCore

# UI層のテストのみ実行
swift test --package-path Packages/GeoSonarUI

# 全パッケージのテスト実行
swift test
```

### UIテストとE2Eテスト

#### 完全フローテスト
```swift
@Test("完全な宝探しフロー")
func testCompleteTreasureHuntFlow() throws {
    let app = XCUIApplication()
    app.launch()
    
    // チュートリアルスキップ
    app.buttons["チュートリアルをスキップ"].tap()
    
    // マップ選択
    let firstMap = app.cells.firstMatch
    #expect(firstMap.exists)
    firstMap.tap()
    
    // 探索開始
    app.buttons["探索開始"].tap()
    
    // モード切り替えテスト
    app.buttons["ソナーモード"].tap()
    #expect(app.buttons["ソナーピング送信"].exists)
}
```

### パフォーマンステスト

#### Swift Testingでのパフォーマンス測定
```swift
@Test("大量データでの距離計算パフォーマンス")
func testDistanceCalculationPerformance() async {
    let service = ExplorationService()
    let userLocation = CLLocation(latitude: 35.7148, longitude: 139.7753)
    let treasures = generateTestTreasures(count: 1000)
    
    let startTime = CFAbsoluteTimeGetCurrent()
    
    for treasure in treasures {
        _ = service.calculateDistance(from: userLocation, to: treasure.coordinate)
    }
    
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    #expect(timeElapsed < 0.1) // 100ms以内で完了することを期待
}
```