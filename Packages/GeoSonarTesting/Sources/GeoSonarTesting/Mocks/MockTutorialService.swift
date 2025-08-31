import Foundation
import GeoSonarCore

/// Mock implementation of TutorialService for testing
public final class MockTutorialService: TutorialServiceProtocol, @unchecked Sendable {
    
    // State properties
    private var _isFirstLaunch: Bool = true
    private var _isTutorialCompleted: Bool = false
    private var _currentTutorialStep: TutorialStep = .welcome
    private var _isHelpAccessEnabled: Bool = true
    
    // Call tracking properties
    public private(set) var isFirstLaunchCallCount = 0
    public private(set) var markFirstLaunchCompletedCallCount = 0
    public private(set) var isTutorialCompletedCallCount = 0
    public private(set) var markTutorialCompletedCallCount = 0
    public private(set) var getCurrentTutorialStepCallCount = 0
    public private(set) var setCurrentTutorialStepCallCount = 0
    public private(set) var advanceToNextStepCallCount = 0
    public private(set) var skipTutorialCallCount = 0
    public private(set) var resetTutorialCallCount = 0
    public private(set) var isHelpAccessEnabledCallCount = 0
    public private(set) var setHelpAccessEnabledCallCount = 0
    public private(set) var shouldShowTutorialCallCount = 0
    public private(set) var getTutorialProgressCallCount = 0
    
    public init(
        isFirstLaunch: Bool = true,
        isTutorialCompleted: Bool = false,
        currentTutorialStep: TutorialStep = .welcome,
        isHelpAccessEnabled: Bool = true
    ) {
        self._isFirstLaunch = isFirstLaunch
        self._isTutorialCompleted = isTutorialCompleted
        self._currentTutorialStep = currentTutorialStep
        self._isHelpAccessEnabled = isHelpAccessEnabled
    }
    
    // MARK: - First Launch Detection
    
    public func isFirstLaunch() async -> Bool {
        isFirstLaunchCallCount += 1
        return _isFirstLaunch
    }
    
    public func markFirstLaunchCompleted() async {
        markFirstLaunchCompletedCallCount += 1
        _isFirstLaunch = false
    }
    
    // MARK: - Tutorial Completion State
    
    public func isTutorialCompleted() async -> Bool {
        isTutorialCompletedCallCount += 1
        return _isTutorialCompleted
    }
    
    public func markTutorialCompleted() async {
        markTutorialCompletedCallCount += 1
        _isTutorialCompleted = true
        _currentTutorialStep = .completed
    }
    
    // MARK: - Tutorial Progress Management
    
    public func getCurrentTutorialStep() async -> TutorialStep {
        getCurrentTutorialStepCallCount += 1
        return _currentTutorialStep
    }
    
    public func setCurrentTutorialStep(_ step: TutorialStep) async {
        setCurrentTutorialStepCallCount += 1
        _currentTutorialStep = step
    }
    
    public func advanceToNextStep() async {
        advanceToNextStepCallCount += 1
        if let nextStep = _currentTutorialStep.nextStep {
            _currentTutorialStep = nextStep
        }
    }
    
    // MARK: - Tutorial Skip and Reset
    
    public func skipTutorial() async {
        skipTutorialCallCount += 1
        _isTutorialCompleted = true
        _currentTutorialStep = .completed
        _isFirstLaunch = false
    }
    
    public func resetTutorial() async {
        resetTutorialCallCount += 1
        _isTutorialCompleted = false
        _currentTutorialStep = .welcome
    }
    
    // MARK: - Help Access Management
    
    public func isHelpAccessEnabled() async -> Bool {
        isHelpAccessEnabledCallCount += 1
        return _isHelpAccessEnabled
    }
    
    public func setHelpAccessEnabled(_ enabled: Bool) async {
        setHelpAccessEnabledCallCount += 1
        _isHelpAccessEnabled = enabled
    }
    
    // MARK: - Tutorial State Queries
    
    public func shouldShowTutorial() async -> Bool {
        shouldShowTutorialCallCount += 1
        return _isFirstLaunch || !_isTutorialCompleted
    }
    
    public func getTutorialProgress() async -> Double {
        getTutorialProgressCallCount += 1
        let allSteps = TutorialStep.allCases
        guard let currentIndex = allSteps.firstIndex(of: _currentTutorialStep) else {
            return 0.0
        }
        return Double(currentIndex) / Double(allSteps.count - 1)
    }
    
    // MARK: - Test Helpers
    
    /// Reset all call counts for testing
    public func resetCallCounts() {
        isFirstLaunchCallCount = 0
        markFirstLaunchCompletedCallCount = 0
        isTutorialCompletedCallCount = 0
        markTutorialCompletedCallCount = 0
        getCurrentTutorialStepCallCount = 0
        setCurrentTutorialStepCallCount = 0
        advanceToNextStepCallCount = 0
        skipTutorialCallCount = 0
        resetTutorialCallCount = 0
        isHelpAccessEnabledCallCount = 0
        setHelpAccessEnabledCallCount = 0
        shouldShowTutorialCallCount = 0
        getTutorialProgressCallCount = 0
    }
    
    /// Set state directly for testing
    public func setState(
        isFirstLaunch: Bool? = nil,
        isTutorialCompleted: Bool? = nil,
        currentTutorialStep: TutorialStep? = nil,
        isHelpAccessEnabled: Bool? = nil
    ) {
        if let isFirstLaunch = isFirstLaunch {
            _isFirstLaunch = isFirstLaunch
        }
        if let isTutorialCompleted = isTutorialCompleted {
            _isTutorialCompleted = isTutorialCompleted
        }
        if let currentTutorialStep = currentTutorialStep {
            _currentTutorialStep = currentTutorialStep
        }
        if let isHelpAccessEnabled = isHelpAccessEnabled {
            _isHelpAccessEnabled = isHelpAccessEnabled
        }
    }
}