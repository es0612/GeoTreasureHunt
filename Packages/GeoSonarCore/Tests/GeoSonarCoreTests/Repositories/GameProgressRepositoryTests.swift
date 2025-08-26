import Testing
import Foundation
import GeoSonarCore

@Suite("GameProgressRepository Protocol Tests")
struct GameProgressRepositoryTests {
    
    @Test("GameProgressRepositoryError should provide localized descriptions")
    func testGameProgressRepositoryErrorDescriptions() {
        let errors: [GameProgressRepositoryError] = [
            .saveFailed,
            .loadFailed,
            .dataCorrupted,
            .storageUnavailable,
            .invalidData
        ]
        
        for error in errors {
            #expect(error.errorDescription != nil)
            #expect(!error.errorDescription!.isEmpty)
        }
    }
    
    @Test("GameProgressRepositoryError should be Sendable")
    func testGameProgressRepositoryErrorSendable() {
        let error: GameProgressRepositoryError = .saveFailed
        
        // This test verifies that the error type conforms to Sendable
        // If it compiles, the test passes
        Task {
            let _ = error
        }
    }
}