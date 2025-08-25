import Testing
import SwiftUI
@testable import GeoSonarUI

@Suite("GeoSonarUI Basic Tests")
struct GeoSonarUITests {
    
    @Test("Package version is accessible")
    func testPackageVersion() {
        #expect(GeoSonarUI.version == "1.0.0")
    }
}