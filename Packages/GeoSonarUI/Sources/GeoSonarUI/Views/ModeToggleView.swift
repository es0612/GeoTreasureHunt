import SwiftUI
import GeoSonarCore

/// A view that allows users to toggle between exploration modes
@available(iOS 15.0, macOS 12.0, *)
public struct ModeToggleView: View {
    // MARK: - Properties
    
    private let currentMode: ExplorationMode
    private let onModeChange: (ExplorationMode) -> Void
    
    // MARK: - Initialization
    
    public init(currentMode: ExplorationMode, onModeChange: @escaping (ExplorationMode) -> Void) {
        self.currentMode = currentMode
        self.onModeChange = onModeChange
    }
    
    // MARK: - Body
    
    public var body: some View {
        HStack(spacing: 0) {
            dowsingButton
            sonarButton
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Exploration mode selector")
    }
    
    private var dowsingButton: some View {
        Button(action: {
            if ExplorationMode.dowsing != currentMode {
                onModeChange(.dowsing)
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: iconForMode(.dowsing))
                    .font(.system(size: 16, weight: .medium))
                
                Text(ExplorationMode.dowsing.localizedDescription)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(ExplorationMode.dowsing == currentMode ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(ExplorationMode.dowsing == currentMode ? Color.blue : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(ExplorationMode.dowsing.localizedDescription)
        .accessibilityHint(ExplorationMode.dowsing == currentMode ? "Currently selected" : "Double tap to switch to dowsing mode")
        .accessibilityAddTraits(ExplorationMode.dowsing == currentMode ? [.isButton, .isSelected] : .isButton)
    }
    
    private var sonarButton: some View {
        Button(action: {
            if ExplorationMode.sonar != currentMode {
                onModeChange(.sonar)
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: iconForMode(.sonar))
                    .font(.system(size: 16, weight: .medium))
                
                Text(ExplorationMode.sonar.localizedDescription)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(ExplorationMode.sonar == currentMode ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(ExplorationMode.sonar == currentMode ? Color.blue : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(ExplorationMode.sonar.localizedDescription)
        .accessibilityHint(ExplorationMode.sonar == currentMode ? "Currently selected" : "Double tap to switch to sonar mode")
        .accessibilityAddTraits(ExplorationMode.sonar == currentMode ? [.isButton, .isSelected] : .isButton)
    }
    
    // MARK: - Private Methods
    
    private func iconForMode(_ mode: ExplorationMode) -> String {
        switch mode {
        case .dowsing:
            return "location.north.line.fill"
        case .sonar:
            return "dot.radiowaves.left.and.right"
        }
    }
}

