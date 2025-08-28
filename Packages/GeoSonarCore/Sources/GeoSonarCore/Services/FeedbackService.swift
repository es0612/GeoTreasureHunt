import Foundation
import AVFoundation
import CoreHaptics

/// Service responsible for providing audio, haptic, and visual feedback during treasure hunting
@available(iOS 13.0, macOS 10.15, *)
public final class FeedbackService: FeedbackServiceProtocol, @unchecked Sendable {
    
    // MARK: - Private Properties
    
    private var audioPlayer: AVAudioPlayer?
    #if os(iOS)
    private var hapticEngine: CHHapticEngine?
    #endif
    
    // MARK: - Initialization
    
    public init() {
        setupAudioSession()
        setupHapticEngine()
    }
    
    // MARK: - FeedbackServiceProtocol Implementation
    
    public func calculateFeedbackIntensity(for distance: Double) -> FeedbackIntensity {
        // Handle edge cases
        let clampedDistance = max(0.0, distance)
        
        switch clampedDistance {
        case 0.0..<10.0:
            return .veryStrong
        case 10.0..<50.0:
            return .strong
        case 50.0..<100.0:
            return .medium
        default:
            return .weak
        }
    }
    
    public func calculateAudioVolume(intensity: FeedbackIntensity, settings: GameSettings) -> Float {
        guard settings.audioEnabled else { return 0.0 }
        
        // Clamp settings volume to valid range
        let clampedVolume = max(0.0, min(1.0, settings.audioVolume))
        
        // Calculate volume based on intensity
        let intensityMultiplier = Float(intensity.numericValue)
        return clampedVolume * intensityMultiplier
    }
    
    public func calculateHapticIntensity(intensity: FeedbackIntensity, settings: GameSettings) -> Float {
        guard settings.hapticsEnabled else { return 0.0 }
        
        return Float(intensity.numericValue)
    }
    
    public func calculatePulseAnimationSettings(intensity: FeedbackIntensity) -> PulseAnimationSettings {
        switch intensity {
        case .weak:
            return PulseAnimationSettings(frequency: 0.5, amplitude: 0.3, duration: 0.5)
        case .medium:
            return PulseAnimationSettings(frequency: 1.0, amplitude: 0.5, duration: 0.4)
        case .strong:
            return PulseAnimationSettings(frequency: 2.0, amplitude: 0.7, duration: 0.3)
        case .veryStrong:
            return PulseAnimationSettings(frequency: 4.0, amplitude: 1.0, duration: 0.2)
        }
    }
    
    public func calculatePulseColor(intensity: FeedbackIntensity) -> FeedbackColor {
        switch intensity {
        case .weak:
            return .weakSonar
        case .medium:
            return .mediumSonar
        case .strong:
            return .strongSonar
        case .veryStrong:
            return .veryStrongSonar
        }
    }
    
    public func provideSonarFeedback(distance: Double, settings: GameSettings) async -> Bool {
        let intensity = calculateFeedbackIntensity(for: distance)
        
        var success = true
        
        // Provide audio feedback
        if settings.audioEnabled {
            let volume = calculateAudioVolume(intensity: intensity, settings: settings)
            let audioSuccess = await playAudioFeedback(volume: volume)
            success = success && audioSuccess
        }
        
        // Provide haptic feedback
        if settings.hapticsEnabled {
            let hapticIntensity = calculateHapticIntensity(intensity: intensity, settings: settings)
            let hapticSuccess = await provideHapticFeedback(intensity: hapticIntensity)
            success = success && hapticSuccess
        }
        
        return success
    }
    
    public func provideHapticFeedback(intensity: Float) async -> Bool {
        guard intensity > 0.0 else { return true }
        
        #if os(iOS)
        guard let engine = hapticEngine else { return false }
        
        do {
            // Create haptic pattern based on intensity
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
            
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [sharpness, intensityParam],
                relativeTime: 0
            )
            
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            
            try await player.start(atTime: 0)
            return true
        } catch {
            return false
        }
        #else
        // Haptic feedback not available on macOS
        return true
        #endif
    }
    
    public func playAudioFeedback(volume: Float) async -> Bool {
        guard volume > 0.0 else { return true }
        
        do {
            // Create a simple beep sound programmatically
            let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
            let frameCount = AVAudioFrameCount(44100 * 0.1) // 0.1 second beep
            
            guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount) else {
                return false
            }
            
            audioBuffer.frameLength = frameCount
            
            // Generate a simple sine wave beep
            let frequency: Float = 800.0 // Hz
            let amplitude: Float = volume * 0.5 // Reduce amplitude to prevent clipping
            
            guard let channelData = audioBuffer.floatChannelData?[0] else {
                return false
            }
            
            for frame in 0..<Int(frameCount) {
                let sampleTime = Float(frame) / 44100.0
                channelData[frame] = amplitude * sin(2.0 * .pi * frequency * sampleTime)
            }
            
            audioPlayer = try AVAudioPlayer(data: audioBufferToData(audioBuffer), fileTypeHint: AVFileType.wav.rawValue)
            audioPlayer?.volume = volume
            audioPlayer?.play()
            
            return true
        } catch {
            return false
        }
    }
    
    // MARK: - Private Methods
    
    private func setupAudioSession() {
        #if os(iOS)
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            // Audio session setup failed, but we can continue without audio
        }
        #endif
    }
    
    private func setupHapticEngine() {
        #if os(iOS)
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            // Haptic engine setup failed, but we can continue without haptics
            hapticEngine = nil
        }
        #endif
    }
    
    private func audioBufferToData(_ buffer: AVAudioPCMBuffer) -> Data {
        let audioFormat = buffer.format
        let audioFile = try! AVAudioFile(
            forWriting: URL(fileURLWithPath: NSTemporaryDirectory().appending("temp.wav")),
            settings: audioFormat.settings
        )
        try! audioFile.write(from: buffer)
        
        return try! Data(contentsOf: audioFile.url)
    }
}