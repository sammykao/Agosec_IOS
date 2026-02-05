import UIKit
import SwiftUI
import StoreKit
import SharedCore
import UIComponents
import KeyboardKit

class KeyboardViewController: KeyboardInputViewController {

    private var keyboardState = KeyboardState()
    private lazy var heightCoordinator = KeyboardHeightCoordinator(view: view)
    private lazy var autocompleteService = SimpleAutocompleteService()
    private let entitlementCoordinator = KeyboardEntitlementCoordinator()

    private var currentHostingView: UIView?
    private var entitlementTask: Task<Void, Never>?
    private var heightUpdateWorkItem: DispatchWorkItem?
    private var delayedHeightUpdateWorkItem: DispatchWorkItem?

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
        entitlementTask?.cancel()
        heightUpdateWorkItem?.cancel()
        delayedHeightUpdateWorkItem?.cancel()
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
            self.scheduleHeightUpdate()
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(openAgentModeFromToolbar),
            name: Notification.Name("KeyboardOpenAgentMode"),
            object: nil
        )
    }

    @objc private func openAgentModeFromToolbar() {
        guard keyboardState.currentMode != .agent else { return }
        showAgentKeyboard()
    }

    private func setupKeyboardKit() {
        setup(for: .agosec) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.services.autocompleteService = self.autocompleteService
                self.configureAutocompleteSettings()
                self.setupKeyboard()
            }
        }
    }

    private func configureAutocompleteSettings() {
        let settings = state.autocompleteContext.settings
        settings.isAutocompleteEnabled = true
        settings.isAutocorrectEnabled = true
        settings.isEmojiAutocompleteEnabled = false
        settings.isNextCharacterPredictionEnabled = false
        settings.isNextWordPredictionEnabled = false
    }

    private func writeFullAccessStatusIfNeeded() {
        let value = hasFullAccess
        guard lastWrittenFullAccess != value else { return }
        lastWrittenFullAccess = value
        AppGroupStorage.shared.set(value, for: AppGroupKeys.keyboardHasFullAccess)
        AppGroupStorage.shared.synchronize()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Update height again after view appears - ensures correct sizing
        scheduleHeightUpdate()
        scheduleHeightUpdate(delay: 0.2)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heightCoordinator.syncConstraintIfNeeded(
            mode: keyboardState.currentMode,
            isExpanded: keyboardState.isExpanded,
            keyboardContext: state.keyboardContext
        )
    }

    override func textWillChange(_ textInput: UITextInput?) {
        // Called when text is about to change
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        // Called after text changed - update suggestions
        // Notify the keyboard view to refresh suggestions
        NotificationCenter.default.post(name: NSNotification.Name("KeyboardTextDidChange"), object: nil)
        updateAutocomplete()
    }

    private func updateAutocomplete() {
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        let fullText = before

        Task { [weak self] in
            guard let self = self else { return }
            do {
                let result = try await self.services.autocompleteService.autocomplete(fullText)
                await MainActor.run {
                    self.state.autocompleteContext.update(with: result)
                }
            } catch {
                await MainActor.run {
                    self.state.autocompleteContext.update(with: error)
                }
            }
        }
    }

    override func viewWillSetupKeyboardView() {
        if isSafeMode {
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
        loadEntitlementState()
        updateHeight()
    }

    private func loadEntitlementState() {
        // Load cached entitlement (fast, synchronous)
        keyboardState.entitlementState = entitlementCoordinator.cachedEntitlement()
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
        entitlementTask?.cancel()
        entitlementTask = Task { [weak self] in
            // Query Apple StoreKit directly for subscription status
            let entitlement = await self?.entitlementCoordinator.refreshEntitlement()
            await MainActor.run {
                guard let self = self, let entitlement = entitlement else { return }
                self.keyboardState.entitlementState = entitlement
                self.keyboardState.hasFullAccess = self.hasFullAccess
            }
        }
    }
}

extension KeyboardViewController {
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
        scheduleHeightUpdate(delay: 0.12)
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

        setupKeyboardView { [weak self] controller in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(
                LayeredAgentKeyboardView(
                    controller: controller,
                    onClose: { self.showTypingKeyboard() },
                    textDocumentProxy: self.textDocumentProxy,
                    keyboardState: self.state
                )
                .environmentObject(ToastManager.shared)
            )
        }

        // Force immediate height update
        scheduleHeightUpdate()
        scheduleHeightUpdate(delay: 0.1)
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
        heightCoordinator.updateHeight(
            mode: keyboardState.currentMode,
            isExpanded: keyboardState.isExpanded,
            keyboardContext: state.keyboardContext,
            inputView: inputView
        )
    }

    private func scheduleHeightUpdate(delay: TimeInterval? = nil) {
        if let delay = delay {
            delayedHeightUpdateWorkItem?.cancel()
            let workItem = DispatchWorkItem { [weak self] in
                self?.updateHeight()
            }
            delayedHeightUpdateWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
            return
        }

        heightUpdateWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.updateHeight()
        }
        heightUpdateWorkItem = workItem
        DispatchQueue.main.async(execute: workItem)
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
