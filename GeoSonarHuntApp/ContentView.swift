import SwiftUI
import GeoSonarCore
import GeoSonarUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "location.magnifyingglass")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Geo Sonar Hunt")
                .font(.title)
            Text("Version: \(GeoSonarCore.version)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}