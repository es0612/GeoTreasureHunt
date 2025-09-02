import SwiftUI
import GeoSonarCore
import GeoSonarTesting

/// Settings view for configuring audio and haptic feedback
@available(iOS 15.0, macOS 14.0, *)
public struct SettingsView: View {
    
    @State private var viewModel: SettingsViewModel
    
    @available(iOS 15.0, macOS 14.0, *)
    public init(viewModel: SettingsViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                audioSection
                hapticsSection
                resetSection
            }
            .navigationTitle("設定")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .task {
                await viewModel.loadSettings()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView("設定を読み込み中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white.opacity(0.8))
                }
            }
        }
    }
    
    // MARK: - Audio Section
    
    @ViewBuilder
    private var audioSection: some View {
        Section("オーディオ") {
            Toggle("音響フィードバック", isOn: Binding(
                get: { viewModel.audioEnabled },
                set: { _ in
                    Task {
                        await viewModel.toggleAudioEnabled()
                    }
                }
            ))
            .accessibilityIdentifier("audioEnabledToggle")
            
            if viewModel.audioEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("音量")
                        Spacer()
                        Text("\(Int(viewModel.audioVolume * 100))%")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(
                        value: Binding(
                            get: { viewModel.audioVolume },
                            set: { newValue in
                                Task {
                                    await viewModel.updateAudioVolume(newValue)
                                }
                            }
                        ),
                        in: 0...1,
                        step: 0.1
                    )
                    .accessibilityIdentifier("audioVolumeSlider")
                    .accessibilityLabel("音量スライダー")
                    .accessibilityValue("\(Int(viewModel.audioVolume * 100))パーセント")
                }
                .animation(.easeInOut(duration: 0.2), value: viewModel.audioEnabled)
            }
        }
        .accessibilityElement(children: .contain)
    }
    
    // MARK: - Haptics Section
    
    @ViewBuilder
    private var hapticsSection: some View {
        Section("ハプティック") {
            Toggle("振動フィードバック", isOn: Binding(
                get: { viewModel.hapticsEnabled },
                set: { _ in
                    Task {
                        await viewModel.toggleHapticsEnabled()
                    }
                }
            ))
            .accessibilityIdentifier("hapticsEnabledToggle")
        }
        .accessibilityElement(children: .contain)
    }
    
    // MARK: - Reset Section
    
    @ViewBuilder
    private var resetSection: some View {
        Section {
            Button("デフォルトに戻す") {
                Task {
                    await viewModel.resetToDefaults()
                }
            }
            .foregroundColor(.red)
            .accessibilityIdentifier("resetButton")
            .accessibilityLabel("設定をデフォルトに戻す")
        } footer: {
            Text("すべての設定をデフォルト値に戻します。")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

@available(iOS 15.0, macOS 14.0, *)
#Preview {
    SettingsView(
        viewModel: SettingsViewModel(
            settingsRepository: LocalGameSettingsRepository()
        )
    )
}