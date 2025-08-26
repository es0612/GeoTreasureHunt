import Testing
import Foundation
import GeoSonarCore

@Suite("TreasureMapRepository Protocol Tests")
struct TreasureMapRepositoryTests {
    
    @Test("TreasureMapRepositoryError should provide localized descriptions")
    func testTreasureMapRepositoryErrorDescriptions() {
        let errors: [TreasureMapRepositoryError] = [
            .dataCorrupted,
            .fileNotFound,
            .invalidFormat,
            .networkUnavailable
        ]
        
        for error in errors {
            #expect(error.errorDescription != nil)
            #expect(!error.errorDescription!.isEmpty)
        }
    }
    
    @Test("TreasureMapRepositoryError should be Sendable")
    func testTreasureMapRepositoryErrorSendable() {
        let error: TreasureMapRepositoryError = .dataCorrupted
        
        // This test verifies that the error type conforms to Sendable
        // If it compiles, the test passes
        Task {
            let _ = error
        }
    }
}