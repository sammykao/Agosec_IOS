import UIKit
import SwiftUI
import StoreKit
import SharedCore
import UIComponents
import KeyboardKit

class KeyboardViewController: KeyboardInputViewController {
    
    private var keyboardState = KeyboardState()
    private var keyboardHeightManager: KeyboardHeightManager!
    private var entitlementChecker: StoreKitEntitlementChecker!
    
    private var currentHostingView: UIView?
    private var heightConstraint: NSLayoutConstraint?
    
    // Track desired height for the keyboard
    private var desiredHeight: CGFloat = 260
    private var isUpdatingHeight = false
    
    // Track if we're in the middle of a photo selection flow
    // This prevents viewWillAppear from resetting the view during photo selection
    private var isInPhotoSelectionFlow = false

    private var lastWrittenFullAccess: Bool?

    private var isSafeMode: Bool {
        if let flag = Bundle.main.object(forInfoDictionaryKey: "KEYBOARD_SAFE_MODE") as? Bool {
            return flag
        }
        return ProcessInfo.processInfo.environment["AGOSEC_KEYBOARD_SAFE_MODE"] == "1"
    }

    override func loadView() {
        // Let KeyboardKit handle view setup completely
        super.loadView()
        configureInputAssistant()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        initializeState()
        configureInputAssistant()
        configureObservers()
        writeFullAccessStatusIfNeeded()
        setupKeyboardKit()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func photoSelectionStarted() {
        isInPhotoSelectionFlow = true
    }
    
    @objc private func photoSelectionEnded() {
        // Delay clearing the flag to ensure keyboard view is stable
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isInPhotoSelectionFlow = false
            // Ensure keyboard view is properly displayed
            self.updateHeight()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isSafeMode {
            keyboardState.hasFullAccess = hasFullAccess
            loadEntitlementState()
            updateHeight()
            if hasFullAccess {
                checkEntitlement()
            }
            return
        }

        configureInputAssistant()
        writeFullAccessStatusIfNeeded()
        
        // Refresh state each time keyboard appears
        keyboardState.hasFullAccess = hasFullAccess
        
        // Always refresh entitlement state to catch demo period changes
        // This ensures demo period is detected even if it was set after keyboard last loaded
        loadEntitlementState()
        
        // State should already be initialized in viewDidLoad
        // Ensure state is properly initialized (currentMode is not optional, but we check if state needs reset)
        // No need to check for nil since currentMode is not optional
        
        // KeyboardKit handles view setup via viewWillSetupKeyboardView
        // Just ensure height is updated
        updateHeight()
        
        if hasFullAccess {
            checkEntitlement()
        }
    }

    private func initializeState() {
        keyboardState.currentMode = .normal
        keyboardState.isExpanded = false
        keyboardState.hasFullAccess = hasFullAccess
    }

    private func configureInputAssistant() {
        if #available(iOS 13.0, *) {
            inputAssistantItem.leadingBarButtonGroups = []
            inputAssistantItem.trailingBarButtonGroups = []
            inputAssistantItem.allowsHidingShortcuts = true
        }
    }

    private func configureObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(photoSelectionStarted),
            name: NSNotification.Name("PhotoSelectionStarted"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(photoSelectionEnded),
            name: NSNotification.Name("PhotoSelectionEnded"),
            object: nil
        )
    }

    private func setupKeyboardKit() {
        setup(for: .agosec) { [weak self] _ in
            DispatchQueue.main.async {
                self?.setupKeyboard()
            }
        }
    }

    private func writeFullAccessStatusIfNeeded() {
        let value = hasFullAccess
        guard lastWrittenFullAccess != value else { return }
        lastWrittenFullAccess = value
        AppGroupStorage.shared.set(value, for: AppGroupKeys.keyboardHasFullAccess)
        AppGroupStorage.shared.synchronize()
    }

    private func ensureManagers() {
        if keyboardHeightManager == nil {
            keyboardHeightManager = KeyboardHeightManager(view: view)
        }
        if entitlementChecker == nil {
            entitlementChecker = StoreKitEntitlementChecker()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Update height again after view appears - ensures correct sizing
        DispatchQueue.main.async {
            self.updateHeight()
        }
        
        // Also update after a longer delay to catch any layout changes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.updateHeight()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Guard against accessing keyboardHeightManager before it's initialized
        guard let keyboardHeightManager = keyboardHeightManager else {
            return
        }
        
        // Only update if we're not in the middle of a height change
        // This prevents viewDidLayoutSubviews from overriding our intentional height changes
        let currentCalculatedHeight = keyboardHeightManager.calculateHeight(
            mode: keyboardState.currentMode,
            isExpanded: keyboardState.isExpanded
        )
        
        // Only update if the constraint doesn't match what it should be
        if abs(heightConstraint?.constant ?? 0 - currentCalculatedHeight) > 5 {
            heightConstraint?.constant = currentCalculatedHeight
            desiredHeight = currentCalculatedHeight
        }
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // Called when text is about to change
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        // Called after text changed - update suggestions
        // Notify the keyboard view to refresh suggestions
        NotificationCenter.default.post(name: NSNotification.Name("KeyboardTextDidChange"), object: nil)
    }
    
    override func viewWillSetupKeyboardView() {
        if isSafeMode {
            ensureManagers()

            if !hasFullAccess {
                setupKeyboardView { [weak self] _ in
                    guard let self = self else { return AnyView(EmptyView()) }
                    return AnyView(FullAccessRequiredView {
                        self.openKeyboardSettings()
                    })
                }
                return
            }

            showKeyboardKitTypingView()
            return
        }
        ensureManagers()

        if !hasFullAccess {
            setupKeyboardView { [weak self] _ in
                guard let self = self else { return AnyView(EmptyView()) }
                return AnyView(FullAccessRequiredView {
                    self.openKeyboardSettings()
                })
            }
            return
        }

        if keyboardState.currentMode == .agent {
            showAgentKeyboard()
            return
        }

        showKeyboardKitTypingView()
    }
    
    private func setupKeyboard() {
        ensureManagers()
        loadEntitlementState()
        updateHeight()
    }
    
    private func loadEntitlementState() {
        // Load cached entitlement (fast, synchronous)
        keyboardState.entitlementState = entitlementChecker.getCachedEntitlement()
        keyboardState.hasFullAccess = hasFullAccess
    }
    
    private func setupInitialView() {
        // Priority 1: Check Full Access first
        if !hasFullAccess {
            showFullAccessRequiredView()
            return
        }
        
        // Priority 2: Show typing keyboard (agent mode requires subscription)
        // Agent mode will be entered via toggleAgentMode() when user taps the button
        showTypingKeyboard()
    }
    
    private func checkEntitlement() {
        Task {
            // Query Apple StoreKit directly for subscription status
            await entitlementChecker.refreshEntitlement()
            await MainActor.run {
                loadEntitlementState()
            }
        }
    }
    
    private func showFullAccessRequiredView() {
        clearSubviews()
        
        let fullAccessView = FullAccessRequiredView {
            self.openKeyboardSettings()
        }
        
        embedSwiftUIView(fullAccessView)
        keyboardState.currentMode = .normal
        keyboardState.isExpanded = false
    }
    
    private func showLockedView() {
        clearSubviews()
        
        let lockedView = LockedView {
            self.openContainerApp()
        }
        
        embedSwiftUIView(lockedView)
        keyboardState.currentMode = .normal
        keyboardState.isExpanded = false
    }
    
    private func showTypingKeyboard() {
        clearSubviews()
        
        // Update state
        keyboardState.currentMode = .normal
        keyboardState.isExpanded = false

        if hasFullAccess {
            showKeyboardKitTypingView()
        } else {
            showFullAccessRequiredView()
        }
        updateHeight()
    }

    private func showKeyboardKitTypingView() {
        setupKeyboardView { controller in
            return AnyView(KeyboardKitTypingView(controller: controller))
        }
    }
    
    private func showAgentKeyboard() {
        clearSubviews()
        
        // Refresh entitlement state to catch demo period changes
        // This ensures demo period is re-checked each time agent mode is toggled
        loadEntitlementState()
        
        if keyboardState.isLocked {
            if let demoEntitlement = EntitlementEvaluator.demoEntitlement(
                requiresOnboardingIncomplete: true
            ) {
                keyboardState.entitlementState = demoEntitlement
            }
        }
        
        // Check if user is subscribed before showing agent mode
        if keyboardState.isLocked {
            showLockedView()
            return
        }
        
        // Update state FIRST before embedding view
        keyboardState.currentMode = .agent
        keyboardState.isExpanded = true
        
        let agentView = AgentKeyboardView(
            onClose: { self.showTypingKeyboard() },
            textDocumentProxy: textDocumentProxy,
            keyboardState: state
        )
        .environmentObject(ToastManager.shared)
        
        embedSwiftUIView(agentView)
        
        // Force immediate height update
        updateHeight()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateHeight()
        }
    }
    
    private func embedSwiftUIView<V: View>(_ swiftUIView: V) {
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.view.backgroundColor = .clear
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
        currentHostingView = hostingController.view
    }
    
    private func toggleAgentMode() {
        if keyboardState.currentMode == .normal {
            showAgentKeyboard()
        } else {
            showTypingKeyboard()
        }
    }
    
    private func updateHeight() {
        // Guard against accessing keyboardHeightManager before it's initialized
        guard let keyboardHeightManager = keyboardHeightManager else {
            return
        }

        guard !isUpdatingHeight else { return }
        isUpdatingHeight = true
        defer { isUpdatingHeight = false }
        
        let height = keyboardHeightManager.calculateHeight(
            mode: keyboardState.currentMode,
            isExpanded: keyboardState.isExpanded
        )

        // Store desired height
        desiredHeight = height

        // Update height constraint on main view
        if heightConstraint == nil {
            let constraint = view.heightAnchor.constraint(equalToConstant: height)
            constraint.priority = .init(999)
            constraint.isActive = true
            self.heightConstraint = constraint
        } else if let current = heightConstraint?.constant, abs(current - height) < 1 {
            return
        } else {
            heightConstraint?.constant = height
        }
        
        // Force layout updates throughout the hierarchy
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        // CRITICAL: Also update the view's frame directly
        var viewFrame = view.frame
        viewFrame.size.height = height
        view.frame = viewFrame
        
        // Update superview if it exists
        view.superview?.setNeedsLayout()
        view.superview?.layoutIfNeeded()
        
        // Also update the window if available
        if let window = view.window {
            window.setNeedsLayout()
            window.layoutIfNeeded()
        }
        
        // Force the input view to update its frame as well
        if let inputView = inputView {
            var inputFrame = inputView.frame
            inputFrame.size.height = height
            inputView.frame = inputFrame
            inputView.setNeedsLayout()
            inputView.layoutIfNeeded()
        }
    }
    
    private func clearSubviews() {
        children.forEach { child in
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        currentHostingView = nil
    }
    
    private func openContainerApp() {
        guard let url = URL(string: "agosec://subscribe") else { return }
        extensionContext?.open(url)
    }
    
    private func openKeyboardSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        extensionContext?.open(url)
    }
}
