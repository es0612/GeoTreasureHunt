import SwiftUI
import GeoSonarCore

/// View for displaying errors with recovery options
public struct ErrorView: View {
    let error: GameError
    let onDismiss: () -> Void
    let onRetry: (() -> Void)?
    
    public init(
        error: GameError,
        onDismiss: @escaping () -> Void,
        onRetry: (() -> Void)? = nil
    ) {
        self.error = error
        self.onDismiss = onDismiss
        self.onRetry = onRetry
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            // Error Icon
            Image(systemName: iconName)
                .font(.system(size: 48))
                .foregroundColor(iconColor)
            
            // Error Title
            Text(errorTitle)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Error Description
            Text(error.errorDescription ?? "不明なエラーが発生しました")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            // Recovery Suggestion
            if let suggestion = error.recoverySuggestion {
                Text(suggestion)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // Action Buttons
            HStack(spacing: 16) {
                // Dismiss Button
                Button("閉じる") {
                    onDismiss()
                }
                .buttonStyle(.bordered)
                
                // Retry Button (if available)
                if let onRetry = onRetry, error.isRecoverable {
                    Button("再試行") {
                        onRetry()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 8)
        .padding(.horizontal, 32)
    }
    
    private var iconName: String {
        switch error.severity {
        case .critical:
            return "exclamationmark.triangle.fill"
        case .error:
            return "xmark.circle.fill"
        case .warning:
            return "exclamationmark.circle.fill"
        case .minor:
            return "info.circle.fill"
        }
    }
    
    private var iconColor: Color {
        switch error.severity {
        case .critical:
            return .red
        case .error:
            return .red
        case .warning:
            return .orange
        case .minor:
            return .blue
        }
    }
    
    private var errorTitle: String {
        switch error.severity {
        case .critical:
            return "重要なエラー"
        case .error:
            return "エラー"
        case .warning:
            return "警告"
        case .minor:
            return "お知らせ"
        }
    }
}

/// Error overlay modifier for easy integration
public struct ErrorOverlay: ViewModifier {
    @Binding var error: GameError?
    let onRetry: (() -> Void)?
    
    public func body(content: Content) -> some View {
        content
            .overlay {
                if let error = error {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .overlay {
                            ErrorView(
                                error: error,
                                onDismiss: {
                                    self.error = nil
                                },
                                onRetry: onRetry
                            )
                        }
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: error != nil)
                }
            }
    }
}

public extension View {
    /// Add error handling overlay to any view
    func errorOverlay(
        error: Binding<GameError?>,
        onRetry: (() -> Void)? = nil
    ) -> some View {
        modifier(ErrorOverlay(error: error, onRetry: onRetry))
    }
}

#Preview {
    VStack {
        Text("Main Content")
            .padding()
    }
    .errorOverlay(
        error: .constant(GameError.gpsSignalWeak),
        onRetry: {
            print("Retry tapped")
        }
    )
}