import Testing
import GeoSonarCore
@testable import GeoSonarTesting

@Suite("MockFeedbackService Tests")
struct MockFeedbackServiceTests {
    
    @Test("Mock should track feedback intensity calculation calls")
    func testFeedbackIntensityTracking() async throws {
        let mock = MockFeedbackService()
        mock.mockFeedbackIntensity = .strong
        
        let intensity = mock.calculateFeedbackIntensity(for: 25.0)
        
        #expect(intensity == .strong)
        #expect(mock.calculateFeedbackIntensityCalls.count == 1)
        #expect(mock.calculateFeedbackIntensityCalls[0] == 25.0)
    }
    
    @Test("Mock should track audio volume calculation calls")
    func testAudioVolumeTracking() async throws {
        let mock = MockFeedbackService()
        let settings = GameSettings(audioEnabled: true, hapticsEnabled: true, audioVolume: 0.8)
        mock.mockAudioVolume = 0.6
        
        let volume = mock.calculateAudioVolume(intensity: .medium, settings: settings)
        
        #expect(volume == 0.6)
        #expect(mock.calculateAudioVolumeCalls.count == 1)
        #expect(mock.calculateAudioVolumeCalls[0].0 == .medium)
        #expect(mock.calculateAudioVolumeCalls[0].1.audioVolume == 0.8)
    }
    
    @Test("Mock should track haptic intensity calculation calls")
    func testHapticIntensityTracking() async throws {
        let mock = MockFeedbackService()
        let settings = GameSettings(audioEnabled: true, hapticsEnabled: true, audioVolume: 0.8)
        mock.mockHapticIntensity = 0.7
        
        let intensity = mock.calculateHapticIntensity(intensity: .strong, settings: settings)
        
        #expect(intensity == 0.7)
        #expect(mock.calculateHapticIntensityCalls.count == 1)
        #expect(mock.calculateHapticIntensityCalls[0].0 == .strong)
        #expect(mock.calculateHapticIntensityCalls[0].1.hapticsEnabled == true)
    }
    
    @Test("Mock should track pulse animation settings calls")
    func testPulseAnimationSettingsTracking() async throws {
        let mock = MockFeedbackService()
        let customSettings = PulseAnimationSettings(frequency: 3.0, amplitude: 0.8, duration: 0.2)
        mock.mockPulseAnimationSettings = customSettings
        
        let settings = mock.calculatePulseAnimationSettings(intensity: .veryStrong)
        
        #expect(settings.frequency == 3.0)
        #expect(settings.amplitude == 0.8)
        #expect(settings.duration == 0.2)
        #expect(mock.calculatePulseAnimationSettingsCalls.count == 1)
        #expect(mock.calculatePulseAnimationSettingsCalls[0] == .veryStrong)
    }
    
    @Test("Mock should track pulse color calls")
    func testPulseColorTracking() async throws {
        let mock = MockFeedbackService()
        mock.mockPulseColor = .veryStrongSonar
        
        let color = mock.calculatePulseColor(intensity: .veryStrong)
        
        #expect(color.alpha == 1.0)
        #expect(mock.calculatePulseColorCalls.count == 1)
        #expect(mock.calculatePulseColorCalls[0] == .veryStrong)
    }
    
    @Test("Mock should track sonar feedback calls")
    func testSonarFeedbackTracking() async throws {
        let mock = MockFeedbackService()
        let settings = GameSettings(audioEnabled: true, hapticsEnabled: true, audioVolume: 0.7)
        mock.mockSonarFeedbackSuccess = true
        
        let success = await mock.provideSonarFeedback(distance: 15.0, settings: settings)
        
        #expect(success == true)
        #expect(mock.provideSonarFeedbackCalls.count == 1)
        #expect(mock.provideSonarFeedbackCalls[0].0 == 15.0)
        #expect(mock.provideSonarFeedbackCalls[0].1.audioVolume == 0.7)
    }
    
    @Test("Mock should track haptic feedback calls")
    func testHapticFeedbackTracking() async throws {
        let mock = MockFeedbackService()
        mock.mockHapticFeedbackSuccess = true
        
        let success = await mock.provideHapticFeedback(intensity: 0.8)
        
        #expect(success == true)
        #expect(mock.provideHapticFeedbackCalls.count == 1)
        #expect(mock.provideHapticFeedbackCalls[0] == 0.8)
    }
    
    @Test("Mock should track audio feedback calls")
    func testAudioFeedbackTracking() async throws {
        let mock = MockFeedbackService()
        mock.mockAudioFeedbackSuccess = true
        
        let success = await mock.playAudioFeedback(volume: 0.6)
        
        #expect(success == true)
        #expect(mock.playAudioFeedbackCalls.count == 1)
        #expect(mock.playAudioFeedbackCalls[0] == 0.6)
    }
    
    @Test("Mock should reset state properly")
    func testReset() async throws {
        let mock = MockFeedbackService()
        
        // Set up some state
        mock.mockFeedbackIntensity = .veryStrong
        mock.mockAudioVolume = 0.9
        _ = mock.calculateFeedbackIntensity(for: 10.0)
        _ = await mock.provideSonarFeedback(distance: 20.0, settings: .default)
        
        // Verify state is set
        #expect(mock.mockFeedbackIntensity == .veryStrong)
        #expect(mock.mockAudioVolume == 0.9)
        #expect(mock.calculateFeedbackIntensityCalls.count == 1)
        #expect(mock.provideSonarFeedbackCalls.count == 1)
        
        // Reset
        mock.reset()
        
        // Verify state is reset
        #expect(mock.mockFeedbackIntensity == .medium)
        #expect(mock.mockAudioVolume == 0.5)
        #expect(mock.calculateFeedbackIntensityCalls.isEmpty)
        #expect(mock.provideSonarFeedbackCalls.isEmpty)
        #expect(mock.calculateAudioVolumeCalls.isEmpty)
        #expect(mock.calculateHapticIntensityCalls.isEmpty)
    }
    
    @Test("Mock should setup strong feedback scenario")
    func testSetupStrongFeedback() async throws {
        let mock = MockFeedbackService()
        
        mock.setupStrongFeedback()
        
        #expect(mock.mockFeedbackIntensity == .strong)
        #expect(mock.mockAudioVolume == 0.8)
        #expect(mock.mockHapticIntensity == 0.8)
        #expect(mock.mockPulseAnimationSettings.frequency == 2.0)
        #expect(mock.mockPulseColor.alpha == 0.7) // strongSonar alpha
    }
    
    @Test("Mock should setup weak feedback scenario")
    func testSetupWeakFeedback() async throws {
        let mock = MockFeedbackService()
        
        mock.setupWeakFeedback()
        
        #expect(mock.mockFeedbackIntensity == .weak)
        #expect(mock.mockAudioVolume == 0.2)
        #expect(mock.mockHapticIntensity == 0.2)
        #expect(mock.mockPulseAnimationSettings.frequency == 0.5)
        #expect(mock.mockPulseColor.alpha == 0.3) // weakSonar alpha
    }
    
    @Test("Mock should setup feedback failure scenario")
    func testSetupFeedbackFailure() async throws {
        let mock = MockFeedbackService()
        
        mock.setupFeedbackFailure()
        
        let sonarSuccess = await mock.provideSonarFeedback(distance: 10.0, settings: .default)
        let hapticSuccess = await mock.provideHapticFeedback(intensity: 0.5)
        let audioSuccess = await mock.playAudioFeedback(volume: 0.5)
        
        #expect(sonarSuccess == false)
        #expect(hapticSuccess == false)
        #expect(audioSuccess == false)
    }
}