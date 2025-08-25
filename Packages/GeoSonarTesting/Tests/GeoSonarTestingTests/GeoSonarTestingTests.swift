import Testing
@testable import GeoSonarTesting

@Suite("GeoSonarTesting Basic Tests")
struct GeoSonarTestingTests {
    
    @Test("Package version is accessible")
    func testPackageVersion() {
        #expect(GeoSonarTesting.version == "1.0.0")
    }
}