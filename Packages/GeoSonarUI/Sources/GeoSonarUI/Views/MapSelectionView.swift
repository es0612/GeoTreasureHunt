import SwiftUI
import GeoSonarCore

/// A view that displays a list of available treasure maps for selection
@available(iOS 17.0, macOS 14.0, *)
public struct MapSelectionView: View {
    // MARK: - Properties
    
    @State private var viewModel: MapSelectionViewModel
    
    // MARK: - Initialization
    
    public init(viewModel: MapSelectionViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    // MARK: - Body
    
    public var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(errorMessage)
                } else if viewModel.availableMaps.isEmpty {
                    emptyStateView
                } else {
                    mapListView
                }
            }
            .navigationTitle("宝の地図")
#if os(iOS)
            .navigationBarTitleDisplayMode(.large)
#endif
            .task {
                await viewModel.loadMaps()
            }
            .refreshable {
                await viewModel.loadMaps()
            }
        }
        .accessibilityLabel("Map Selection Screen")
    }
    
    // MARK: - Private Views
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("地図を読み込み中...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityLabel("Loading maps")
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("エラーが発生しました")
                .font(.headline)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("再試行") {
                Task {
                    await viewModel.loadMaps()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityLabel("Error loading maps")
        .accessibilityHint("Double tap retry button to reload maps")
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "map")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("地図がありません")
                .font(.headline)
            
            Text("利用可能な宝の地図がありません")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityLabel("No maps available")
    }
    
    private var mapListView: some View {
        List(viewModel.availableMaps) { map in
            MapRowView(treasureMap: map) {
                Task {
                    let _ = await viewModel.selectMap(map)
                    // Navigation to exploration view would be handled by parent
                    // For now, we just create the session
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .padding(.vertical, 4)
        }
        .listStyle(.plain)
        .accessibilityLabel("Available treasure maps")
    }
}

// MARK: - Preview

@available(iOS 17.0, macOS 14.0, *)
#Preview {
    // Preview is simplified to avoid mock dependencies
    Text("MapSelectionView Preview")
        .navigationTitle("宝の地図")
}