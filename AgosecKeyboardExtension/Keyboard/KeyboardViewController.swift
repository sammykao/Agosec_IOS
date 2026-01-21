import UIKit
import SwiftUI
import StoreKit
import SharedCore
import UIComponents

class KeyboardViewController: UIInputViewController {
    
    private var keyboardState = KeyboardState()
    private var keyboardHeightManager: KeyboardHeightManager!
    private var entitlementChecker: StoreKitEntitlementChecker!
    
    private var currentHostingView: UIView?
    private var heightConstraint: NSLayoutConstraint?
    
    // Track desired height for the keyboard
    private var desiredHeight: CGFloat = 260
    
    // Track if we're in the middle of a photo selection flow
    // This prevents viewWillAppear from resetting the view during photo selection
    private var isInPhotoSelectionFlow = false
    
    // Custom resizable input view
    private var resizableInputView: ResizableInputView?
    
    override func loadView() {
        // Create custom resizable input view
        let customInputView = ResizableInputView(frame: .zero, inputViewStyle: .keyboard)
        customInputView.translatesAutoresizingMaskIntoConstraints = false
        customInputView.allowsSelfSizing = true
        self.resizableInputView = customInputView
        
        // Set inputView (inherited from UIInputViewController, type is UIInputView?)
        self.inputView = customInputView
        // Set view to the same custom view
        self.view = customInputView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupKeyboard()
        
        // Listen for photo selection flow notifications
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func photoSelectionStarted() {
        print("📸 Photo selection started - setting flag to prevent reset")
        isInPhotoSelectionFlow = true
    }
    
    @objc private func photoSelectionEnded() {
        print("📸 Photo selection ended - clearing flag")
        isInPhotoSelectionFlow = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Save full access status to App Group for main app to read
        AppGroupStorage.shared.set(hasFullAccess, for: "keyboard_has_full_access")
        AppGroupStorage.shared.synchronize()
        
        // Refresh state each time keyboard appears
        keyboardState.hasFullAccess = hasFullAccess
        
        // Always refresh entitlement state to catch demo period changes
        // This ensures demo period is detected even if it was set after keyboard last loaded
        loadEntitlementState()
        
        // Only setup initial view if we don't already have a view embedded
        // AND we're not in the middle of a photo selection flow
        // This prevents resetting when sheet dismisses and viewWillAppear is called
        if currentHostingView == nil && !isInPhotoSelectionFlow {
            print("🔄 viewWillAppear: No existing view, setting up initial view")
            setupInitialView()
        } else if isInPhotoSelectionFlow {
            print("🔄 viewWillAppear: In photo selection flow, preserving current view (mode: \(keyboardState.currentMode))")
            // Just update height to match current mode, don't reset
            updateHeight()
        } else {
            print("🔄 viewWillAppear: View already exists (mode: \(keyboardState.currentMode)), skipping setup")
            // Just update height to match current mode
            updateHeight()
        }
        
        if hasFullAccess {
            checkEntitlement()
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
        // Only update if we're not in the middle of a height change
        // This prevents viewDidLayoutSubviews from overriding our intentional height changes
        let currentCalculatedHeight = keyboardHeightManager.calculateHeight(
            mode: keyboardState.currentMode,
            isExpanded: keyboardState.isExpanded
        )
        
        // Only update if the constraint doesn't match what it should be
        if abs(heightConstraint?.constant ?? 0 - currentCalculatedHeight) > 5 {
            print("📐 viewDidLayoutSubviews: correcting height from \(heightConstraint?.constant ?? 0) to \(currentCalculatedHeight)")
            heightConstraint?.constant = currentCalculatedHeight
            desiredHeight = currentCalculatedHeight
            resizableInputView?.setHeight(currentCalculatedHeight, animated: false)
        }
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // Called when text is about to change
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // Called after text changed - update suggestions
        // Notify the keyboard view to refresh suggestions
        NotificationCenter.default.post(name: NSNotification.Name("KeyboardTextDidChange"), object: nil)
    }
    
    private func setupKeyboard() {
        keyboardHeightManager = KeyboardHeightManager(view: view)
        entitlementChecker = StoreKitEntitlementChecker()
        
        loadEntitlementState()
        setupInitialView()
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
        
        let typingView = TypingKeyboardView(
            onAgentModeTapped: { self.toggleAgentMode() },
            onKeyTapped: { key in self.handleKeyPress(key) },
            inputViewController: self,
            textDocumentProxy: textDocumentProxy
        )
        
        embedSwiftUIView(typingView)
        keyboardState.currentMode = .normal
        keyboardState.isExpanded = false
        updateHeight()
    }
    
    private func showAgentKeyboard() {
        clearSubviews()
        
        // Refresh entitlement state to catch demo period changes
        // This ensures demo period is re-checked each time agent mode is toggled
        loadEntitlementState()
        
        // Double-check demo period directly if still locked
        // This handles cases where entitlement state might be stale
        if keyboardState.isLocked {
            print("🔍 User appears locked, checking demo period...")
            // Check demo period directly as a fallback
            let onboardingComplete: Bool = AppGroupStorage.shared.get(Bool.self, for: "onboarding_complete") ?? false
            print("🔍 Onboarding complete: \(onboardingComplete)")
            
            if !onboardingComplete {
                if let demoStartDate: Date = AppGroupStorage.shared.get(Date.self, for: "demo_period_start_date") {
                    let demoDuration: TimeInterval = 48 * 60 * 60 // 48 hours
                    let demoExpiration = demoStartDate.addingTimeInterval(demoDuration)
                    let now = Date()
                    print("🔍 Demo start: \(demoStartDate), expiration: \(demoExpiration), now: \(now), expired: \(now >= demoExpiration)")
                    
                    if now < demoExpiration {
                        // Demo period is active - grant access
                        print("✅ Demo period detected directly - granting access")
                        keyboardState.entitlementState = EntitlementState(
                            isActive: true,
                            expiresAt: demoExpiration,
                            productId: Config.shared.subscriptionProductId
                        )
                    } else {
                        print("❌ Demo period expired")
                    }
                } else {
                    print("❌ No demo period start date found")
                }
            } else {
                print("❌ Onboarding complete - demo period not applicable")
            }
        }
        
        print("🔐 Final check - isLocked: \(keyboardState.isLocked), entitlement: \(keyboardState.entitlementState)")
        
        // Check if user is subscribed before showing agent mode
        if keyboardState.isLocked {
            print("⚠️ User is locked - showing LockedView instead of Agent")
            showLockedView()
            return
        }
        
        // Update state FIRST before embedding view
        keyboardState.currentMode = .agent
        keyboardState.isExpanded = true
        
        print("🚀 Setting mode to .agent, isExpanded: true")
        
        let agentView = AgentKeyboardView(
            onClose: { self.showTypingKeyboard() },
            textDocumentProxy: textDocumentProxy
        )
        .environmentObject(ToastManager.shared)
        
        embedSwiftUIView(agentView)
        
        print("🚀 Agent keyboard shown - updating height to 80%")
        print("📱 Screen height: \(UIScreen.main.bounds.height)")
        print("📐 Expected agent height: \(UIScreen.main.bounds.height * 0.80)")
        
        // Force immediate height update
        updateHeight()
        
        // Update multiple times to ensure it takes - keyboard extensions need multiple attempts
        DispatchQueue.main.async {
            print("📐 Update 1 (immediate async)")
            self.updateHeight()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            print("📐 Update 2 (0.05s delay)")
            self.updateHeight()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            print("📐 Update 3 (0.15s delay)")
            self.updateHeight()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            print("📐 Update 4 (0.3s delay)")
            self.updateHeight()
        }
        
        // Final update after view is fully laid out
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("📐 Update 5 (0.5s delay) - Final")
            self.updateHeight()
            print("📐 Final desired height: \(self.desiredHeight)")
            print("📐 Final constraint height: \(self.heightConstraint?.constant ?? 0)")
            print("📐 Final resizableInputView height: \(self.resizableInputView?.intrinsicContentSize.height ?? 0)")
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
        print("🔄 toggleAgentMode called - current mode: \(keyboardState.currentMode)")
        
        if keyboardState.currentMode == .normal {
            print("📱 Switching to Agent mode")
            showAgentKeyboard()
        } else {
            print("⌨️ Switching to Typing mode")
            showTypingKeyboard()
        }
    }
    
    private func handleKeyPress(_ key: Key) {
        switch key.type {
        case .character:
            textDocumentProxy.insertText(key.value)
        case .backspace:
            textDocumentProxy.deleteBackward()
        case .space:
            textDocumentProxy.insertText(" ")
        case .return:
            textDocumentProxy.insertText("\n")
        case .arrow:
            textDocumentProxy.insertText("\n")
        case .shift:
            break
        case .symbol:
            break
        case .emoji:
            break
        }
    }
    
    private func updateHeight() {
        let height = keyboardHeightManager.calculateHeight(
            mode: keyboardState.currentMode,
            isExpanded: keyboardState.isExpanded
        )
        
        print("📏 updateHeight called - calculated: \(height), mode: \(keyboardState.currentMode), expanded: \(keyboardState.isExpanded)")
        
        // Store desired height
        desiredHeight = height
        
        // CRITICAL: Update the input view's intrinsic content size FIRST
        // This is what iOS keyboard extensions use to determine height
        if let resizableView = resizableInputView {
            // Update the resizable input view's height - this is the primary method
            resizableView.setHeight(height, animated: true)
            
            // Invalidate intrinsic content size - this tells iOS to resize the keyboard
            resizableView.invalidateIntrinsicContentSize()
        }
        
        // Update height constraint on main view as backup
        if heightConstraint == nil {
            let constraint = view.heightAnchor.constraint(equalToConstant: height)
            constraint.priority = .init(999)
            constraint.isActive = true
            self.heightConstraint = constraint
            print("📐 Created new height constraint: \(height)")
        } else {
            heightConstraint?.constant = height
            print("📐 Updated height constraint to: \(height)")
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

