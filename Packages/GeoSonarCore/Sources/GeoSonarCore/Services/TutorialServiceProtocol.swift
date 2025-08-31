import Foundation

/// Protocol for tutorial service functionality
public protocol TutorialServiceProtocol: Sendable {
    
    // MARK: - First Launch Detection
    
    /// Check if this is the first launch of the app
    func isFirstLaunch() async -> Bool
    
    /// Mark the first launch as completed
    func markFirstLaunchCompleted() async
    
    // MARK: - Tutorial Completion State
    
    /// Check if the tutorial has been completed
    func isTutorialCompleted() async -> Bool
    
    /// Mark the tutorial as completed
    func markTutorialCompleted() async
    
    // MARK: - Tutorial Progress Management
    
    /// Get the current tutorial step
    func getCurrentTutorialStep() async -> TutorialStep
    
    /// Set the current tutorial step
    func setCurrentTutorialStep(_ step: TutorialStep) async
    
    /// Advance to the next tutorial step
    func advanceToNextStep() async
    
    // MARK: - Tutorial Skip and Reset
    
    /// Skip the tutorial and mark it as completed
    func skipTutorial() async
    
    /// Reset the tutorial to initial state
    func resetTutorial() async
    
    // MARK: - Help Access Management
    
    /// Check if help access is enabled
    func isHelpAccessEnabled() async -> Bool
    
    /// Set help access enabled state
    func setHelpAccessEnabled(_ enabled: Bool) async
    
    // MARK: - Tutorial State Queries
    
    /// Check if the tutorial should be shown
    func shouldShowTutorial() async -> Bool
    
    /// Get tutorial progress as a percentage (0.0 to 1.0)
    func getTutorialProgress() async -> Double
}