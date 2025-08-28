import SwiftUI
import GeoSonarCore

/// A view that displays a compass-like interface for dowsing mode navigation
@available(iOS 15.0, macOS 12.0, *)
public struct DowsingCompassView: View {
    // MARK: - Properties
    
    private let direction: Double
    
    // MARK: - State
    
    @State private var animationRotation: Double = 0
    
    // MARK: - Initialization
    
    public init(direction: Double) {
        self.direction = direction
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack {
            // Outer compass ring
            Circle()
                .stroke(Color.gray.opacity(0.6), lineWidth: 2)
                .frame(width: 200, height: 200)
            
            // Compass rose background
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 180, height: 180)
            
            // Cardinal direction markers
            ForEach(0..<4) { index in
                Rectangle()
                    .fill(Color.gray.opacity(0.7))
                    .frame(width: 2, height: 20)
                    .offset(y: -80)
                    .rotationEffect(.degrees(Double(index) * 90))
            }
            
            // Cardinal direction labels
            ForEach(Array(cardinalDirections.enumerated()), id: \.offset) { index, label in
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .offset(y: -65)
                    .rotationEffect(.degrees(Double(index) * 90))
            }
            
            // Direction needle
            ZStack {
                // Needle shaft
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.red)
                    .frame(width: 4, height: 60)
                    .offset(y: -20)
                
                // Needle point
                Triangle()
                    .fill(Color.red)
                    .frame(width: 12, height: 16)
                    .offset(y: -58)
                
                // Needle base
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
            }
            .rotationEffect(.degrees(normalizedDirection))
            .animation(.easeInOut(duration: 0.5), value: normalizedDirection)
            
            // Center dot
            Circle()
                .fill(Color.primary)
                .frame(width: 6, height: 6)
            
            // Direction text
            VStack {
                Spacer()
                
                Text(directionDescription)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    )
                    .offset(y: 40)
            }
        }
        .frame(width: 220, height: 220)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Dowsing compass")
        .accessibilityValue("Treasure direction: \(directionDescription)")
        .accessibilityHint("The needle points toward the nearest treasure")
        .onAppear {
            animationRotation = normalizedDirection
        }
        .onChange(of: direction) { newDirection in
            animationRotation = normalizeDirection(newDirection)
        }
    }
    
    // MARK: - Private Computed Properties
    
    private var normalizedDirection: Double {
        return normalizeDirection(direction)
    }
    
    private var cardinalDirections: [String] {
        return ["N", "E", "S", "W"]
    }
    
    private var directionDescription: String {
        let normalizedDir = normalizedDirection
        
        switch normalizedDir {
        case 0..<22.5, 337.5..<360:
            return "North"
        case 22.5..<67.5:
            return "Northeast"
        case 67.5..<112.5:
            return "East"
        case 112.5..<157.5:
            return "Southeast"
        case 157.5..<202.5:
            return "South"
        case 202.5..<247.5:
            return "Southwest"
        case 247.5..<292.5:
            return "West"
        case 292.5..<337.5:
            return "Northwest"
        default:
            return "North"
        }
    }
    
    // MARK: - Private Methods
    
    private func normalizeDirection(_ direction: Double) -> Double {
        var normalized = direction.truncatingRemainder(dividingBy: 360)
        if normalized < 0 {
            normalized += 360
        }
        return normalized
    }
}

// MARK: - Triangle Shape

@available(iOS 15.0, macOS 12.0, *)
private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}

