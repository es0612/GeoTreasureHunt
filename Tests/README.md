# E2Eテストスイート

Geo Sonar Hunt アプリの包括的なEnd-to-End（E2E）テストスイートです。

## 概要

このテストスイートは、アプリの全機能を実際のユーザー操作に近い形でテストし、要件仕様書に定義された全ての要件が正しく実装されていることを検証します。

## テストカテゴリ

### 1. 完全な宝探しフローテスト (`CompleteTreasureHuntFlowTests`)

**目的**: アプリの基本的な宝探しフローが正常に動作することを検証

**テスト内容**:
- アプリ起動からマップ選択まで
- 探索画面への遷移
- モード切り替え（ダウジング ⇔ ソナー）
- 宝発見プロセス
- ゲーム完了処理

**対象要件**: 1.1, 1.2, 3.1, 3.2, 4.1, 5.1, 5.2, 6.1, 6.2

**実行時間**: 約5-10分

### 2. 複数シナリオテスト (`MultipleScenarioTests`)

**目的**: 様々な使用シナリオとエラー処理の検証

**テスト内容**:
- 複数宝発見シナリオ
- 設定変更シナリオ（音量、ハプティック）
- エラー処理シナリオ（GPS弱、位置情報拒否、データ破損）
- パフォーマンステストシナリオ

**対象要件**: 1.1, 1.2, 6.1, 6.2, 6.5, 7.1, 7.2, 8.1-8.5, 2.3, 2.5, 10.4, 10.5

**実行時間**: 約10-15分

### 3. アクセシビリティテスト (`AccessibilityTests`)

**目的**: アクセシビリティ機能の適切な実装を検証

**テスト内容**:
- VoiceOver対応
- Dynamic Type対応
- 色覚サポート
- ハイコントラストモード対応
- アクセシビリティラベル・ヒントの設定

**対象要件**: 5.1, 5.2（アクセシビリティ対応）

**実行時間**: 約8-12分

### 4. パフォーマンステスト (`PerformanceTests`)

**目的**: アプリのパフォーマンスと資源使用量の検証

**テスト内容**:
- アプリ起動時間
- 画面遷移応答性
- モード切り替え性能（0.2秒以内）
- 位置更新性能（1秒以内）
- メモリ使用量
- CPU使用率
- ストレージI/O性能

**対象要件**: 2.2, 2.4, 5.2, 4.1, 4.2, 7.1, 7.2

**実行時間**: 約15-20分

### 5. 統合テスト (`ComprehensiveIntegrationTests`)

**目的**: 全要件の統合的な検証

**テスト内容**:
- 要件1-10の全項目を網羅的にテスト
- 各要件の受入基準を個別に検証
- 要件間の相互作用を確認

**対象要件**: 全要件の統合検証

**実行時間**: 約20-30分

## 実行方法

### 前提条件

- Xcode 15.0以上
- iOS Simulator（iPhone 15, iOS 17.0以上）
- xcpretty（推奨）: `gem install xcpretty`

### コマンドライン実行

```bash
# 全E2Eテストの実行
make test-e2e

# 個別カテゴリの実行
make test-e2e-flow           # フローテスト
make test-e2e-scenarios      # シナリオテスト
make test-e2e-accessibility  # アクセシビリティテスト
make test-e2e-performance    # パフォーマンステスト
make test-e2e-integration    # 統合テスト

# スクリプト直接実行
./Tests/run_e2e_tests.sh all
./Tests/run_e2e_tests.sh flow
./Tests/run_e2e_tests.sh scenarios
./Tests/run_e2e_tests.sh accessibility
./Tests/run_e2e_tests.sh performance
./Tests/run_e2e_tests.sh integration
```

### Xcode内での実行

1. Xcode でプロジェクトを開く
2. Test Navigator（⌘+6）を選択
3. `GeoSonarHuntAppUITests` を展開
4. 実行したいテストクラスを選択して実行

## テスト環境設定

テストは以下の環境変数を使用してモック動作を制御します：

- `UITEST_MODE=true`: UIテストモードを有効化
- `MOCK_LOCATION=true`: 位置情報をモック化
- `SKIP_LOCATION_PERMISSION=true`: 位置情報許可をスキップ
- `SIMULATE_WEAK_GPS=true`: GPS信号弱をシミュレーション
- `SIMULATE_LOCATION_DENIED=true`: 位置情報拒否をシミュレーション
- `SIMULATE_DATA_CORRUPTION=true`: データ破損をシミュレーション
- `SIMULATE_OFFLINE=true`: オフライン動作をシミュレーション
- `SIMULATE_FIRST_LAUNCH=true`: 初回起動をシミュレーション

## テスト結果

テスト実行後、以下の場所に結果が保存されます：

- `TestResults/`: テスト結果とログ
- `TestResults/Coverage/`: カバレッジレポート（xcovが利用可能な場合）

## トラブルシューティング

### よくある問題

1. **シミュレーターが起動しない**
   ```bash
   # シミュレーターをリセット
   xcrun simctl shutdown all
   xcrun simctl erase all
   ```

2. **テストがタイムアウトする**
   - シミュレーターの性能を確認
   - 他のアプリを終了してリソースを確保
   - テストタイムアウト値を調整

3. **ビルドエラー**
   ```bash
   # プロジェクトを再生成
   make clean
   make generate
   ```

4. **テストが不安定**
   - シミュレーターを再起動
   - DerivedDataを削除: `rm -rf DerivedData`

### ログとデバッグ

詳細なログを有効にするには：

```bash
# 詳細ログ付きでテスト実行
ENABLE_DETAILED_LOGS=true ./Tests/run_e2e_tests.sh all
```

## CI/CD統合

GitHub Actionsでの実行例：

```yaml
- name: Run E2E Tests
  run: |
    make test-e2e
  env:
    CI: true
    RESET_SIMULATOR: true
```

## 要件トレーサビリティ

各テストクラスは以下の要件をカバーします：

| テストクラス | 対象要件 | 検証内容 |
|-------------|----------|----------|
| CompleteTreasureHuntFlowTests | 1.1, 1.2, 3.1, 3.2, 4.1, 5.1, 5.2, 6.1, 6.2 | 基本フロー |
| MultipleScenarioTests | 1.1, 1.2, 6.1, 6.2, 6.5, 7.1, 7.2, 8.1-8.5, 2.3, 2.5, 10.4, 10.5 | 複数シナリオ |
| AccessibilityTests | 5.1, 5.2, アクセシビリティ対応 | アクセシビリティ |
| PerformanceTests | 2.2, 2.4, 5.2, 4.1, 4.2, 7.1, 7.2 | パフォーマンス |
| ComprehensiveIntegrationTests | 全要件 | 統合検証 |

## メンテナンス

### テストの更新

新機能追加時は以下を更新してください：

1. 対応するテストクラスにテストケースを追加
2. `test_config.json` の要件マッピングを更新
3. このREADMEの要件トレーサビリティ表を更新

### パフォーマンス基準の調整

パフォーマンステストの基準値は以下で調整できます：

- モード切り替え: 0.2秒以内
- 位置更新: 1秒以内
- アプリ起動: 3秒以内
- ソナーフィードバック: 1秒以内

これらの値は `PerformanceTests.swift` 内で調整可能です。