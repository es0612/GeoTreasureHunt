import SwiftUI
import MapKit
import GeoSonarCore

/// A view that provides the main exploration interface for treasure hunting
@available(iOS 17.0, macOS 14.0, *)
public struct ExplorationView: View {
    // MARK: - Properties
    
    @State private var viewModel: ExplorationViewModel
    @State private var showingTreasureDiscovery = false
    @State private var discoveredTreasure: Treasure?
    
    // MARK: - Initialization
    
    public init(viewModel: ExplorationViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack {
            // Background Map
            mapView
            
            // Main UI Overlay
            VStack {
                // Top Controls
                topControlsView
                
                Spacer()
                
                // Mode-specific Interface
                modeInterfaceView
                
                Spacer()
                
                // Bottom Controls
                bottomControlsView
            }
            .padding()
        }
        .navigationTitle("宝探し")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .navigationBarBackButtonHidden(false)
        .task {
            await viewModel.startLocationTracking()
        }
        .onDisappear {
            viewModel.stopLocationTracking()
        }
        .alert("宝を発見しました！", isPresented: $showingTreasureDiscovery) {
            Button("続ける") {
                discoveredTreasure = nil
            }
        } message: {
            if let treasure = discoveredTreasure {
                Text("\(treasure.name)を発見しました！\n+\(treasure.points)ポイント")
            }
        }
        .errorOverlay(
            error: Binding(
                get: { viewModel.currentError },
                set: { _ in Task { await viewModel.clearError() } }
            ),
            onRetry: {
                Task {
                    await viewModel.retryLastOperation()
                }
            }
        )
        .accessibilityLabel("Exploration Screen")
    }
    
    // MARK: - Private Views
    
    private var mapView: some View {
        Map(coordinateRegion: .constant(MKCoordinateRegion(
            center: viewModel.treasureMap.region.center,
            span: MKCoordinateSpan(
                latitudeDelta: viewModel.treasureMap.region.span.latitudeDelta,
                longitudeDelta: viewModel.treasureMap.region.span.longitudeDelta
            )
        )), showsUserLocation: true)
        .ignoresSafeArea()
        .accessibilityLabel("Treasure map")
        .accessibilityHint("Shows your current location and the exploration area")
    }
    
    private var topControlsView: some View {
        HStack {
            // Score Display
            VStack(alignment: .leading, spacing: 4) {
                Text("スコア")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(viewModel.currentSession.totalPoints)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
            
            Spacer()
            
            // Mode Toggle
            ModeToggleView(currentMode: viewModel.currentMode) { mode in
                viewModel.switchMode(to: mode)
            }
        }
        .accessibilityElement(children: .contain)
    }
    
    private var modeInterfaceView: some View {
        Group {
            switch viewModel.currentMode {
            case .dowsing:
                dowsingInterface
            case .sonar:
                sonarInterface
            }
        }
    }
    
    private var dowsingInterface: some View {
        VStack(spacing: 20) {
            // Dowsing Compass
            DowsingCompassView(direction: viewModel.directionToTreasure)
            
            // Distance Information
            if viewModel.distanceToTreasure > 0 {
                VStack(spacing: 4) {
                    Text("最寄りの宝まで")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(viewModel.distanceToTreasure))m")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                )
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Dowsing mode interface")
    }
    
    private var sonarInterface: some View {
        VStack(spacing: 30) {
            // Sonar Button
            Button(action: {
                Task {
                    await viewModel.sendSonarPing()
                }
            }) {
                VStack(spacing: 8) {
                    Image(systemName: "dot.radiowaves.left.and.right")
                        .font(.system(size: 40))
                    
                    Text("ソナーピング送信")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(width: 160, height: 160)
                .background(
                    Circle()
                        .fill(.blue.gradient)
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Send sonar ping")
            .accessibilityHint("Double tap to send a sonar ping and get distance feedback")
            
            // Distance Information
            if viewModel.distanceToTreasure > 0 {
                VStack(spacing: 4) {
                    Text("最寄りの宝まで")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(viewModel.distanceToTreasure))m")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Sonar mode interface")
    }
    
    private var bottomControlsView: some View {
        HStack {
            // Discovered Treasures Count
            VStack(alignment: .leading, spacing: 4) {
                Text("発見済み")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(viewModel.currentSession.discoveredTreasures.count)/\(viewModel.treasureMap.treasures.count)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
            
            Spacer()
            
            // Check for Discovery Button
            Button("宝を探す") {
                Task {
                    if let treasure = await viewModel.checkForTreasureDiscovery() {
                        discoveredTreasure = treasure
                        showingTreasureDiscovery = true
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .accessibilityLabel("Check for treasure discovery")
            .accessibilityHint("Double tap to check if you are close enough to discover a treasure")
        }
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Preview

@available(iOS 17.0, macOS 14.0, *)
#Preview {
    // Preview is simplified to avoid mock dependencies
    NavigationView {
        Text("ExplorationView Preview")
            .navigationTitle("宝探し")
    }
}