#!/bin/bash

# E2Eテストスイート実行スクリプト
# 使用方法: ./Tests/run_e2e_tests.sh [test_type]
# test_type: all, flow, scenarios, accessibility, performance, integration

set -e

# カラー出力の設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ログ関数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# プロジェクト設定
PROJECT_NAME="GeoSonarHunt"
SCHEME_NAME="GeoSonarHuntApp"
SIMULATOR_NAME="iPhone 15"
IOS_VERSION="17.0"

# テストタイプの設定
TEST_TYPE=${1:-"all"}

# シミュレーターの確認と起動
setup_simulator() {
    log_info "シミュレーターの設定を確認中..."
    
    # 利用可能なシミュレーターの確認
    SIMULATOR_ID=$(xcrun simctl list devices | grep "$SIMULATOR_NAME" | grep "$IOS_VERSION" | head -1 | grep -o '[A-F0-9-]\{36\}')
    
    if [ -z "$SIMULATOR_ID" ]; then
        log_error "シミュレーター '$SIMULATOR_NAME ($IOS_VERSION)' が見つかりません"
        log_info "利用可能なシミュレーター:"
        xcrun simctl list devices | grep iPhone
        exit 1
    fi
    
    log_info "シミュレーター ID: $SIMULATOR_ID"
    
    # シミュレーターの起動
    xcrun simctl boot "$SIMULATOR_ID" 2>/dev/null || true
    
    # シミュレーターが起動するまで待機
    log_info "シミュレーターの起動を待機中..."
    timeout=60
    while [ $timeout -gt 0 ]; do
        if xcrun simctl list devices | grep "$SIMULATOR_ID" | grep -q "Booted"; then
            break
        fi
        sleep 1
        timeout=$((timeout - 1))
    done
    
    if [ $timeout -eq 0 ]; then
        log_error "シミュレーターの起動がタイムアウトしました"
        exit 1
    fi
    
    log_success "シミュレーターが起動しました"
}

# プロジェクトのビルド
build_project() {
    log_info "プロジェクトをビルド中..."
    
    xcodebuild -project "$PROJECT_NAME.xcodeproj" \
               -scheme "$SCHEME_NAME" \
               -destination "platform=iOS Simulator,name=$SIMULATOR_NAME,OS=$IOS_VERSION" \
               -derivedDataPath ./DerivedData \
               build-for-testing \
               | xcpretty
    
    if [ $? -eq 0 ]; then
        log_success "プロジェクトのビルドが完了しました"
    else
        log_error "プロジェクトのビルドに失敗しました"
        exit 1
    fi
}

# 個別テストクラスの実行
run_test_class() {
    local test_class=$1
    local test_name=$2
    
    log_info "$test_name を実行中..."
    
    xcodebuild -project "$PROJECT_NAME.xcodeproj" \
               -scheme "$SCHEME_NAME" \
               -destination "platform=iOS Simulator,name=$SIMULATOR_NAME,OS=$IOS_VERSION" \
               -derivedDataPath ./DerivedData \
               test-without-building \
               -only-testing "GeoSonarHuntAppUITests/$test_class" \
               | xcpretty
    
    local result=$?
    if [ $result -eq 0 ]; then
        log_success "$test_name が完了しました"
    else
        log_error "$test_name が失敗しました (終了コード: $result)"
        return $result
    fi
}

# 完全な宝探しフローテストの実行
run_flow_tests() {
    log_info "=== 完全な宝探しフローテスト ==="
    run_test_class "CompleteTreasureHuntFlowTests" "完全な宝探しフローテスト"
}

# 複数シナリオテストの実行
run_scenario_tests() {
    log_info "=== 複数シナリオテスト ==="
    run_test_class "MultipleScenarioTests" "複数シナリオテスト"
}

# アクセシビリティテストの実行
run_accessibility_tests() {
    log_info "=== アクセシビリティテスト ==="
    run_test_class "AccessibilityTests" "アクセシビリティテスト"
}

# パフォーマンステストの実行
run_performance_tests() {
    log_info "=== パフォーマンステスト ==="
    run_test_class "PerformanceTests" "パフォーマンステスト"
}

# 統合テストの実行
run_integration_tests() {
    log_info "=== 統合テスト ==="
    run_test_class "ComprehensiveIntegrationTests" "統合テスト"
    
    # 単体テストも実行
    log_info "=== 単体統合テスト ==="
    xcodebuild -project "$PROJECT_NAME.xcodeproj" \
               -scheme "$SCHEME_NAME" \
               -destination "platform=iOS Simulator,name=$SIMULATOR_NAME,OS=$IOS_VERSION" \
               -derivedDataPath ./DerivedData \
               test-without-building \
               -only-testing "GeoSonarHuntAppTests" \
               | xcpretty
}

# 全テストの実行
run_all_tests() {
    log_info "=== 全E2Eテストスイートの実行 ==="
    
    local failed_tests=()
    
    # 各テストカテゴリを順次実行
    run_flow_tests || failed_tests+=("フローテスト")
    run_scenario_tests || failed_tests+=("シナリオテスト")
    run_accessibility_tests || failed_tests+=("アクセシビリティテスト")
    run_performance_tests || failed_tests+=("パフォーマンステスト")
    run_integration_tests || failed_tests+=("統合テスト")
    
    # 結果の報告
    if [ ${#failed_tests[@]} -eq 0 ]; then
        log_success "全てのE2Eテストが成功しました！"
        return 0
    else
        log_error "以下のテストが失敗しました:"
        for test in "${failed_tests[@]}"; do
            log_error "  - $test"
        done
        return 1
    fi
}

# テスト結果の収集
collect_test_results() {
    log_info "テスト結果を収集中..."
    
    # テスト結果ディレクトリの作成
    mkdir -p TestResults
    
    # DerivedDataからテスト結果をコピー
    if [ -d "./DerivedData/Logs/Test" ]; then
        cp -r ./DerivedData/Logs/Test/* TestResults/ 2>/dev/null || true
        log_success "テスト結果を TestResults/ ディレクトリに保存しました"
    fi
    
    # テストカバレッジレポートの生成（可能な場合）
    if command -v xcov &> /dev/null; then
        log_info "テストカバレッジレポートを生成中..."
        xcov --project "$PROJECT_NAME.xcodeproj" \
             --scheme "$SCHEME_NAME" \
             --output_directory TestResults/Coverage \
             --derived_data_path ./DerivedData
    fi
}

# クリーンアップ
cleanup() {
    log_info "クリーンアップを実行中..."
    
    # シミュレーターのリセット（オプション）
    if [ "$RESET_SIMULATOR" = "true" ]; then
        xcrun simctl shutdown "$SIMULATOR_ID" 2>/dev/null || true
        xcrun simctl erase "$SIMULATOR_ID" 2>/dev/null || true
        log_info "シミュレーターをリセットしました"
    fi
}

# メイン実行部分
main() {
    log_info "E2Eテストスイートを開始します..."
    log_info "テストタイプ: $TEST_TYPE"
    
    # 前提条件の確認
    if ! command -v xcodebuild &> /dev/null; then
        log_error "xcodebuild が見つかりません。Xcode がインストールされていることを確認してください。"
        exit 1
    fi
    
    if ! command -v xcpretty &> /dev/null; then
        log_warning "xcpretty が見つかりません。出力が見にくくなる可能性があります。"
        log_info "インストール: gem install xcpretty"
    fi
    
    # シミュレーターの設定
    setup_simulator
    
    # プロジェクトのビルド
    build_project
    
    # テストの実行
    case $TEST_TYPE in
        "flow")
            run_flow_tests
            ;;
        "scenarios")
            run_scenario_tests
            ;;
        "accessibility")
            run_accessibility_tests
            ;;
        "performance")
            run_performance_tests
            ;;
        "integration")
            run_integration_tests
            ;;
        "all")
            run_all_tests
            ;;
        *)
            log_error "不明なテストタイプ: $TEST_TYPE"
            log_info "利用可能なテストタイプ: all, flow, scenarios, accessibility, performance, integration"
            exit 1
            ;;
    esac
    
    local test_result=$?
    
    # テスト結果の収集
    collect_test_results
    
    # クリーンアップ
    cleanup
    
    # 最終結果の報告
    if [ $test_result -eq 0 ]; then
        log_success "E2Eテストスイートが正常に完了しました！"
    else
        log_error "E2Eテストスイートでエラーが発生しました。"
        exit 1
    fi
}

# スクリプトの実行
main "$@"