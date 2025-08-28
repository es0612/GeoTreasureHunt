import Testing
import AVFoundation
import CoreHaptics
@testable import GeoSonarCore

@Suite("FeedbackService Tests")
struct FeedbackServiceTests {
    
    // MARK: - Sonar Feedback Tests
    
    @Test("ソナーフィードバック - 距離100m以上（弱いフィードバック）")
    func testSonarFeedbackFarDistance() async throws {
        let service = FeedbackService()
        let settings = GameSettings(
            audioEnabled: true,
            hapticsEnabled: true,
            audioVolume: 0.8
        )
        
        // Distance > 100m should provide weak feedback
        let distance = 150.0
        
        // This test verifies the service can handle far distances
        // In a real implementation, this would trigger weak audio and haptic feedback
        #expect(service.calculateFeedbackIntensity(for: distance) == .weak)
    }
    
    @Test("ソナーフィードバック - 距離50-100m（中程度のフィードバック）")
    func testSonarFeedbackMediumDistance() async throws {
        let service = FeedbackService()
        let settings = GameSettings(
            audioEnabled: true,
            hapticsEnabled: true,
            audioVolume: 0.8
        )
        
        // Distance 50-100m should provide medium feedback
        let distance = 75.0
        
        #expect(service.calculateFeedbackIntensity(for: distance) == .medium)
    }
    
    @Test("ソナーフィードバック - 距離10-50m（強いフィードバック）")
    func testSonarFeedbackCloseDistance() async throws {
        let service = FeedbackService()
        let settings = GameSettings(
            audioEnabled: true,
            hapticsEnabled: true,
            audioVolume: 0.8
        )
        
        // Distance 10-50m should provide strong feedback
        let distance = 30.0
        
        #expect(service.calculateFeedbackIntensity(for: distance) == .strong)
    }
    
    @Test("ソナーフィードバック - 距離10m未満（最強のフィードバック）")
    func testSonarFeedbackVeryCloseDistance() async throws {
        let service = FeedbackService()
        let settings = GameSettings(
            audioEnabled: true,
            hapticsEnabled: true,
            audioVolume: 0.8
        )
        
        // Distance < 10m should provide very strong feedback
        let distance = 5.0
        
        #expect(service.calculateFeedbackIntensity(for: distance) == .veryStrong)
    }
    
    @Test("ソナーフィードバック - 境界値テスト")
    func testSonarFeedbackBoundaryValues() async throws {
        let service = FeedbackService()
        
        // Test exact boundary values
        #expect(service.calculateFeedbackIntensity(for: 100.0) == .weak)  // 100.0 is >= 100.0, so weak
        #expect(service.calculateFeedbackIntensity(for: 50.0) == .medium) // 50.0 is in [50.0, 100.0), so medium
        #expect(service.calculateFeedbackIntensity(for: 10.0) == .strong) // 10.0 is in [10.0, 50.0), so strong
        #expect(service.calculateFeedbackIntensity(for: 0.0) == .veryStrong)
    }
    
    // MARK: - Audio Feedback Tests
    
    @Test("音響フィードバック - 音量設定の適用")
    func testAudioFeedbackVolumeSettings() async throws {
        let service = FeedbackService()
        
        let settings1 = GameSettings(audioEnabled: true, hapticsEnabled: true, audioVolume: 0.5)
        let settings2 = GameSettings(audioEnabled: true, hapticsEnabled: true, audioVolume: 1.0)
        
        // Test that volume settings are properly applied
        let volume1 = service.calculateAudioVolume(intensity: .medium, settings: settings1)
        let volume2 = service.calculateAudioVolume(intensity: .medium, settings: settings2)
        
        #expect(volume1 < volume2)
        #expect(volume1 >= 0.0 && volume1 <= 1.0)
        #expect(volume2 >= 0.0 && volume2 <= 1.0)
    }
    
    @Test("音響フィードバック - 音声無効時")
    func testAudioFeedbackDisabled() async throws {
        let service = FeedbackService()
        let settings = GameSettings(audioEnabled: false, hapticsEnabled: true, audioVolume: 0.8)
        
        let volume = service.calculateAudioVolume(intensity: .strong, settings: settings)
        
        #expect(volume == 0.0)
    }
    
    @Test("音響フィードバック - 異なる強度レベル")
    func testAudioFeedbackIntensityLevels() async throws {
        let service = FeedbackService()
        let settings = GameSettings(audioEnabled: true, hapticsEnabled: true, audioVolume: 1.0)
        
        let weakVolume = service.calculateAudioVolume(intensity: .weak, settings: settings)
        let mediumVolume = service.calculateAudioVolume(intensity: .medium, settings: settings)
        let strongVolume = service.calculateAudioVolume(intensity: .strong, settings: settings)
        let veryStrongVolume = service.calculateAudioVolume(intensity: .veryStrong, settings: settings)
        
        // Volumes should increase with intensity
        #expect(weakVolume < mediumVolume)
        #expect(mediumVolume < strongVolume)
        #expect(strongVolume <= veryStrongVolume)
    }
    
    // MARK: - Haptic Feedback Tests
    
    @Test("ハプティックフィードバック - 強度計算")
    func testHapticFeedbackIntensity() async throws {
        let service = FeedbackService()
        let settings = GameSettings(audioEnabled: true, hapticsEnabled: true, audioVolume: 0.8)
        
        let weakIntensity = service.calculateHapticIntensity(intensity: .weak, settings: settings)
        let mediumIntensity = service.calculateHapticIntensity(intensity: .medium, settings: settings)
        let strongIntensity = service.calculateHapticIntensity(intensity: .strong, settings: settings)
        let veryStrongIntensity = service.calculateHapticIntensity(intensity: .veryStrong, settings: settings)
        
        // Haptic intensities should increase with feedback intensity
        #expect(weakIntensity < mediumIntensity)
        #expect(mediumIntensity < strongIntensity)
        #expect(strongIntensity <= veryStrongIntensity)
        
        // All intensities should be within valid range
        #expect(weakIntensity >= 0.0 && weakIntensity <= 1.0)
        #expect(mediumIntensity >= 0.0 && mediumIntensity <= 1.0)
        #expect(strongIntensity >= 0.0 && strongIntensity <= 1.0)
        #expect(veryStrongIntensity >= 0.0 && veryStrongIntensity <= 1.0)
    }
    
    @Test("ハプティックフィードバック - 無効時")
    func testHapticFeedbackDisabled() async throws {
        let service = FeedbackService()
        let settings = GameSettings(audioEnabled: true, hapticsEnabled: false, audioVolume: 0.8)
        
        let intensity = service.calculateHapticIntensity(intensity: .strong, settings: settings)
        
        #expect(intensity == 0.0)
    }
    
    // MARK: - Visual Feedback Tests
    
    @Test("視覚フィードバック - パルスアニメーション設定")
    func testVisualFeedbackPulseAnimation() async throws {
        let service = FeedbackService()
        
        let weakPulse = service.calculatePulseAnimationSettings(intensity: .weak)
        let mediumPulse = service.calculatePulseAnimationSettings(intensity: .medium)
        let strongPulse = service.calculatePulseAnimationSettings(intensity: .strong)
        let veryStrongPulse = service.calculatePulseAnimationSettings(intensity: .veryStrong)
        
        // Pulse frequency should increase with intensity
        #expect(weakPulse.frequency < mediumPulse.frequency)
        #expect(mediumPulse.frequency < strongPulse.frequency)
        #expect(strongPulse.frequency <= veryStrongPulse.frequency)
        
        // All frequencies should be positive
        #expect(weakPulse.frequency > 0.0)
        #expect(mediumPulse.frequency > 0.0)
        #expect(strongPulse.frequency > 0.0)
        #expect(veryStrongPulse.frequency > 0.0)
    }
    
    @Test("視覚フィードバック - 色の強度")
    func testVisualFeedbackColorIntensity() async throws {
        let service = FeedbackService()
        
        let weakColor = service.calculatePulseColor(intensity: .weak)
        let mediumColor = service.calculatePulseColor(intensity: .medium)
        let strongColor = service.calculatePulseColor(intensity: .strong)
        let veryStrongColor = service.calculatePulseColor(intensity: .veryStrong)
        
        // Colors should have different alpha values based on intensity
        #expect(weakColor.alpha < mediumColor.alpha)
        #expect(mediumColor.alpha < strongColor.alpha)
        #expect(strongColor.alpha <= veryStrongColor.alpha)
    }
    
    // MARK: - Integration Tests
    
    @Test("統合テスト - 完全なソナーフィードバック")
    func testCompleteSonarFeedback() async throws {
        let service = FeedbackService()
        let settings = GameSettings(audioEnabled: true, hapticsEnabled: true, audioVolume: 0.7)
        
        let distance = 25.0 // Should trigger strong feedback
        
        // Test that all feedback components work together
        let intensity = service.calculateFeedbackIntensity(for: distance)
        let audioVolume = service.calculateAudioVolume(intensity: intensity, settings: settings)
        let hapticIntensity = service.calculateHapticIntensity(intensity: intensity, settings: settings)
        let pulseSettings = service.calculatePulseAnimationSettings(intensity: intensity)
        let pulseColor = service.calculatePulseColor(intensity: intensity)
        
        #expect(intensity == .strong)
        #expect(audioVolume > 0.0)
        #expect(hapticIntensity > 0.0)
        #expect(pulseSettings.frequency > 0.0)
        #expect(pulseColor.alpha > 0.0)
    }
    
    @Test("統合テスト - すべてのフィードバック無効")
    func testAllFeedbackDisabled() async throws {
        let service = FeedbackService()
        let settings = GameSettings(audioEnabled: false, hapticsEnabled: false, audioVolume: 0.0)
        
        let distance = 15.0
        let intensity = service.calculateFeedbackIntensity(for: distance)
        
        let audioVolume = service.calculateAudioVolume(intensity: intensity, settings: settings)
        let hapticIntensity = service.calculateHapticIntensity(intensity: intensity, settings: settings)
        
        // Audio and haptic should be disabled, but visual feedback should still work
        #expect(audioVolume == 0.0)
        #expect(hapticIntensity == 0.0)
        
        // Visual feedback should still be available
        let pulseSettings = service.calculatePulseAnimationSettings(intensity: intensity)
        #expect(pulseSettings.frequency > 0.0)
    }
    
    // MARK: - Error Handling Tests
    
    @Test("エラーハンドリング - 無効な距離値")
    func testInvalidDistanceValues() async throws {
        let service = FeedbackService()
        
        // Test negative distance
        let negativeIntensity = service.calculateFeedbackIntensity(for: -10.0)
        #expect(negativeIntensity == .veryStrong) // Should treat as very close
        
        // Test very large distance
        let largeIntensity = service.calculateFeedbackIntensity(for: 10000.0)
        #expect(largeIntensity == .weak) // Should treat as very far
    }
    
    @Test("エラーハンドリング - 無効な音量設定")
    func testInvalidVolumeSettings() async throws {
        let service = FeedbackService()
        
        // Test volume > 1.0
        let highVolumeSettings = GameSettings(audioEnabled: true, hapticsEnabled: true, audioVolume: 1.5)
        let volume1 = service.calculateAudioVolume(intensity: .medium, settings: highVolumeSettings)
        #expect(volume1 <= 1.0) // Should be clamped to 1.0
        
        // Test negative volume
        let negativeVolumeSettings = GameSettings(audioEnabled: true, hapticsEnabled: true, audioVolume: -0.5)
        let volume2 = service.calculateAudioVolume(intensity: .medium, settings: negativeVolumeSettings)
        #expect(volume2 >= 0.0) // Should be clamped to 0.0
    }
}