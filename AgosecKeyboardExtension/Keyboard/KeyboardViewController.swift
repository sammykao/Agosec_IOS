import UIKit
import SwiftUI
import SharedCore
import UIComponents

class KeyboardViewController: UIInputViewController {
    
    private var keyboardState = KeyboardState()
    private var keyboardHeightManager: KeyboardHeightManager!
    private var entitlementGate: KeyboardEntitlementGate!
    
    private var typingKeyboardView: UIView?
    private var agentKeyboardView: UIView?
    private var lockedView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Save full access status to App Group for main app to read
        AppGroupStorage.shared.set(hasFullAccess, for: "keyboard_has_full_access")
        
        checkEntitlement()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeight()
    }
    
    private func setupKeyboard() {
        keyboardHeightManager = KeyboardHeightManager(view: view)
        entitlementGate = KeyboardEntitlementGate()
        
        loadEntitlementState()
        setupInitialView()
    }
    
    private func loadEntitlementState() {
        if let entitlement: EntitlementState = AppGroupStorage.shared.get(EntitlementState.self, for: "entitlement_state") {
            keyboardState.entitlementState = entitlement
        }
        
        keyboardState.hasFullAccess = hasFullAccess
    }
    
    private func setupInitialView() {
        if keyboardState.isLocked {
            showLockedView()
        } else {
            showTypingKeyboard()
        }
    }
    
    private func checkEntitlement() {
        Task {
            await entitlementGate.verifyEntitlement()
            await MainActor.run {
                loadEntitlementState()
                setupInitialView()
            }
        }
    }
    
    private func showLockedView() {
        clearSubviews()
        
        let lockedView = LockedView {
            self.openContainerApp()
        }
        
        let hostingController = UIHostingController(rootView: lockedView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        self.lockedView = hostingController.view
    }
    
    private func showTypingKeyboard() {
        clearSubviews()
        
        let typingView = TypingKeyboardView(
            onAgentModeTapped: { self.toggleAgentMode() },
            onKeyTapped: { key in self.handleKeyPress(key) }
        )
        
        let hostingController = UIHostingController(rootView: typingView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        self.typingKeyboardView = hostingController.view
        keyboardState.currentMode = .normal
        keyboardState.isExpanded = false
    }
    
    private func showAgentKeyboard() {
        clearSubviews()
        
        // Check if user is subscribed before showing agent mode
        if keyboardState.isLocked {
            showLockedView()
            return
        }
        
        let agentView = AgentKeyboardView(
            onClose: { self.showTypingKeyboard() },
            textDocumentProxy: textDocumentProxy
        )
        .environmentObject(ToastManager.shared)
        
        let hostingController = UIHostingController(rootView: agentView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        self.agentKeyboardView = hostingController.view
        keyboardState.currentMode = .agent
        keyboardState.isExpanded = true
    }
    
    private func toggleAgentMode() {
        if keyboardState.currentMode == .normal {
            showAgentKeyboard()
        } else {
            showTypingKeyboard()
        }
        updateHeight()
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
        case .shift:
            break // Handle shift toggle
        case .globe:
            advanceToNextInputMode()
        case .symbol:
            break // Handle symbol mode
        }
    }
    
    private func updateHeight() {
        let height = keyboardHeightManager.calculateHeight(
            mode: keyboardState.currentMode,
            isExpanded: keyboardState.isExpanded
        )
        
        let constraints = view.constraintsAffectingLayout(for: .vertical)
        for constraint in constraints {
            if constraint.firstAttribute == .height {
                constraint.constant = height
                break
            }
        }
    }
    
    private func clearSubviews() {
        view.subviews.forEach { $0.removeFromSuperview() }
        children.forEach { $0.removeFromParent() }
        typingKeyboardView = nil
        agentKeyboardView = nil
        lockedView = nil
    }
    
    private func openContainerApp() {
        guard let url = URL(string: "agosec://subscribe") else { return }
        extensionContext?.open(url)
    }
}