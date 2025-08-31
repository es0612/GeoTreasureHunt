import Foundation
import GeoSonarCore

/// ViewModel for managing tutorial state and progression
@available(iOS 15.0, macOS 14.0, *)
@Observable
@MainActor
public final class TutorialViewModel {
    
    // MARK: - Published Properties
    
    public private(set) var isFirstLaunch: Bool = true
    public private(set) var isTutorialCompleted: Bool = false
    public private(set) var currentStep: TutorialStep = .welcome
    public private(set) var shouldShowTutorial: Bool = true
    public private(set) var isHelpAccessEnabled: Bool = true
    public private(set) var isLoading: Bool = false
    
    // MARK: - Dependencies
    
    private let tutorialService: TutorialServiceProtocol
    
    // MARK: - Initialization
    
    public init(tutorialService: TutorialServiceProtocol) {
        self.tutorialService = tutorialService
    }
    
    // MARK: - Public Methods
    
    /// Load current tutorial state from service
    public func loadTutorialState() async {
        isLoading = true
        defer { isLoading = false }
        
        isFirstLaunch = await tutorialService.isFirstLaunch()
        isTutorialCompleted = await tutorialService.isTutorialCompleted()
        currentStep = await tutorialService.getCurrentTutorialStep()
        shouldShowTutorial = await tutorialService.shouldShowTutorial()
        isHelpAccessEnabled = await tutorialService.isHelpAccessEnabled()
    }
    
    /// Advance to the next tutorial step
    public func advanceToNextStep() async {
        await tutorialService.advanceToNextStep()
        currentStep = await tutorialService.getCurrentTutorialStep()
    }
    
    /// Go to a specific tutorial step
    public func goToStep(_ step: TutorialStep) async {
        await tutorialService.setCurrentTutorialStep(step)
        currentStep = step
    }
    
    /// Skip the tutorial
    public func skipTutorial() async {
        await tutorialService.skipTutorial()
        await tutorialService.markFirstLaunchCompleted()
        isTutorialCompleted = await tutorialService.isTutorialCompleted()
        currentStep = await tutorialService.getCurrentTutorialStep()
        shouldShowTutorial = await tutorialService.shouldShowTutorial()
    }
    
    /// Complete the tutorial
    public func completeTutorial() async {
        await tutorialService.markTutorialCompleted()
        isTutorialCompleted = await tutorialService.isTutorialCompleted()
        currentStep = await tutorialService.getCurrentTutorialStep()
        shouldShowTutorial = await tutorialService.shouldShowTutorial()
    }
    
    /// Reset the tutorial to initial state
    public func resetTutorial() async {
        await tutorialService.resetTutorial()
        isTutorialCompleted = await tutorialService.isTutorialCompleted()
        currentStep = await tutorialService.getCurrentTutorialStep()
        shouldShowTutorial = await tutorialService.shouldShowTutorial()
    }
    
    /// Set help access enabled state
    public func setHelpAccessEnabled(_ enabled: Bool) async {
        await tutorialService.setHelpAccessEnabled(enabled)
        isHelpAccessEnabled = enabled
    }
    
    // MARK: - Computed Properties
    
    /// Get tutorial progress as a percentage (0.0 to 1.0)
    public var progress: Double {
        let allSteps = TutorialStep.allCases
        guard let currentIndex = allSteps.firstIndex(of: currentStep) else {
            return 0.0
        }
        return Double(currentIndex) / Double(allSteps.count - 1)
    }
    
    /// Check if current step is welcome
    public var isWelcomeStep: Bool {
        currentStep == .welcome
    }
    
    /// Check if current step is dowsing explanation
    public var isDowsingStep: Bool {
        currentStep == .dowsingExplanation
    }
    
    /// Check if current step is sonar explanation
    public var isSonarStep: Bool {
        currentStep == .sonarExplanation
    }
    
    /// Check if current step is practice mode
    public var isPracticeStep: Bool {
        currentStep == .practiceMode
    }
    
    /// Check if current step is completed
    public var isCompletedStep: Bool {
        currentStep == .completed
    }
    
    /// Check if there is a next step available
    public var hasNextStep: Bool {
        currentStep.nextStep != nil
    }
    
    /// Get the next step if available
    public var nextStep: TutorialStep? {
        currentStep.nextStep
    }
    
    /// Get localized description for current step
    public var currentStepDescription: String {
        currentStep.localizedDescription
    }
}