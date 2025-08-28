import SwiftUI
import GeoSonarCore
import CoreLocation

/// A view that displays a treasure map in a list row format
@available(iOS 15.0, macOS 12.0, *)
public struct MapRowView: View {
    // MARK: - Properties
    
    private let treasureMap: TreasureMap
    private let action: () -> Void
    
    // MARK: - Initialization
    
    public init(treasureMap: TreasureMap, action: @escaping () -> Void) {
        self.treasureMap = treasureMap
        self.action = action
    }
    
    // MARK: - Body
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Map icon
                Image(systemName: "map.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // Map details
                VStack(alignment: .leading, spacing: 4) {
                    Text(treasureMap.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(treasureMap.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack(spacing: 12) {
                        // Difficulty badge
                        HStack(spacing: 4) {
                            Image(systemName: difficultyIcon)
                                .font(.caption)
                            Text(treasureMap.difficulty.localizedDescription)
                                .font(.caption)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(difficultyColor.opacity(0.2))
                        .foregroundColor(difficultyColor)
                        .clipShape(Capsule())
                        
                        Spacer()
                        
                        // Treasure count
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text("\(treasureMap.treasures.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Total points
                        HStack(spacing: 4) {
                            Image(systemName: "trophy.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            Text("\(treasureMap.totalPoints)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to start exploring this treasure map")
        .accessibilityAddTraits(.isButton)
    }
    
    // MARK: - Private Computed Properties
    
    private var difficultyIcon: String {
        switch treasureMap.difficulty {
        case .easy:
            return "leaf.fill"
        case .medium:
            return "flame.fill"
        case .hard:
            return "bolt.fill"
        }
    }
    
    private var difficultyColor: Color {
        switch treasureMap.difficulty {
        case .easy:
            return .green
        case .medium:
            return .orange
        case .hard:
            return .red
        }
    }
    
    private var accessibilityLabel: String {
        return "\(treasureMap.name), \(treasureMap.description), \(treasureMap.difficulty.localizedDescription) difficulty, \(treasureMap.treasures.count) treasures, \(treasureMap.totalPoints) total points"
    }
}

