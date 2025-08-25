import Testing
@testable import GeoSonarCore

@Suite("GeoSonarCore Basic Tests")
struct GeoSonarCoreTests {
    
    @Test("Package version is accessible")
    func testPackageVersion() {
        #expect(GeoSonarCore.version == "1.0.0")
    }
}