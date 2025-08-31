import Foundation

/// Service for managing tutorial state and progression
public final class TutorialService: TutorialServiceProtocol, @unchecked Sendable {
    
    private let userDefaults: UserDefaults
    
    // UserDefaults keys
    private enum Keys {
        static let isFirstLaunch = "tutorial.isFirstLaunch"
        static let isTutorialCompleted = "tutorial.isCompleted"
        static let currentTutorialStep = "tutorial.currentStep"
        static let isHelpAccessEnabled = "tutorial.helpAccessEnabled"
    }
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - First Launch Detection
    
    /// Check if this is the first launch of the app
    public func isFirstLaunch() async -> Bool {
        return !userDefaults.bool(forKey: Keys.isFirstLaunch)
    }
    
    /// Mark the first launch as completed
    public func markFirstLaunchCompleted() async {
        userDefaults.set(true, forKey: Keys.isFirstLaunch)
    }
    
    // MARK: - Tutorial Completion State
    
    /// Check if the tutorial has been completed
    public func isTutorialCompleted() async -> Bool {
        return userDefaults.bool(forKey: Keys.isTutorialCompleted)
    }
    
    /// Mark the tutorial as completed
    public func markTutorialCompleted() async {
        userDefaults.set(true, forKey: Keys.isTutorialCompleted)
        await setCurrentTutorialStep(.completed)
    }
    
    // MARK: - Tutorial Progress Management
    
    /// Get the current tutorial step
    public func getCurrentTutorialStep() async -> TutorialStep {
        guard let stepString = userDefaults.string(forKey: Keys.currentTutorialStep),
              let step = TutorialStep(rawValue: stepString) else {
            return .welcome
        }
        return step
    }
    
    /// Set the current tutorial step
    public func setCurrentTutorialStep(_ step: TutorialStep) async {
        userDefaults.set(step.rawValue, forKey: Keys.currentTutorialStep)
    }
    
    /// Advance to the next tutorial step
    public func advanceToNextStep() async {
        let currentStep = await getCurrentTutorialStep()
        if let nextStep = currentStep.nextStep {
            await setCurrentTutorialStep(nextStep)
        }
    }
    
    // MARK: - Tutorial Skip and Reset
    
    /// Skip the tutorial and mark it as completed
    public func skipTutorial() async {
        await markTutorialCompleted()
        await setCurrentTutorialStep(.completed)
    }
    
    /// Reset the tutorial to initial state
    public func resetTutorial() async {
        userDefaults.removeObject(forKey: Keys.isTutorialCompleted)
        userDefaults.removeObject(forKey: Keys.currentTutorialStep)
    }
    
    // MARK: - Help Access Management
    
    /// Check if help access is enabled
    public func isHelpAccessEnabled() async -> Bool {
        // Default to true if not set
        return userDefaults.object(forKey: Keys.isHelpAccessEnabled) as? Bool ?? true
    }
    
    /// Set help access enabled state
    public func setHelpAccessEnabled(_ enabled: Bool) async {
        userDefaults.set(enabled, forKey: Keys.isHelpAccessEnabled)
    }
    
    // MARK: - Tutorial State Queries
    
    /// Check if the tutorial should be shown
    public func shouldShowTutorial() async -> Bool {
        let isFirst = await isFirstLaunch()
        let isCompleted = await isTutorialCompleted()
        return isFirst || !isCompleted
    }
    
    /// Get tutorial progress as a percentage (0.0 to 1.0)
    public func getTutorialProgress() async -> Double {
        let currentStep = await getCurrentTutorialStep()
        let allSteps = TutorialStep.allCases
        
        guard let currentIndex = allSteps.firstIndex(of: currentStep) else {
            return 0.0
        }
        
        return Double(currentIndex) / Double(allSteps.count - 1)
    }
}