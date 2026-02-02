import UIKit
import KeyboardKit
import SharedCore

final class KeyboardHeightCoordinator {
    private weak var view: UIView?
    private let heightManager: KeyboardHeightManager
    private var heightConstraint: NSLayoutConstraint?
    private var isUpdatingHeight = false

    init(view: UIView) {
        self.view = view
        self.heightManager = KeyboardHeightManager(view: view)
    }

    func syncConstraintIfNeeded(
        mode: KeyboardMode,
        isExpanded: Bool,
        keyboardContext: KeyboardContext
    ) {
        guard mode != .normal else { return }
        guard view != nil else { return }
        
        // If constraint hasn't been created yet, we can't sync it
        guard let constraint = heightConstraint else { return }

        let currentCalculatedHeight = heightManager.calculateHeight(
            mode: mode,
            isExpanded: isExpanded,
            keyboardContext: keyboardContext
        )

        // Only update if the constraint doesn't match what it should be
        if abs(constraint.constant - currentCalculatedHeight) > 5 {
            constraint.constant = currentCalculatedHeight
            // Do NOT call setNeedsLayout() here as it can cause infinite loops
            // The constraint update itself will trigger necessary layout passes
        }
    }

    func updateHeight(
        mode: KeyboardMode,
        isExpanded: Bool,
        keyboardContext: KeyboardContext,
        inputView: UIView?
    ) {
        guard let view = view else { return }
        guard !isUpdatingHeight else { return }
        isUpdatingHeight = true
        defer { isUpdatingHeight = false }

        if mode == .normal {
            clearHeightConstraintIfNeeded()
            view.setNeedsLayout()
            view.layoutIfNeeded()
            inputView?.invalidateIntrinsicContentSize()
            return
        }

        let height = heightManager.calculateHeight(
            mode: mode,
            isExpanded: isExpanded,
            keyboardContext: keyboardContext
        )

        // Update height constraint on main view
        if heightConstraint == nil {
            let constraint = view.heightAnchor.constraint(equalToConstant: height)
            constraint.priority = .init(999)
            constraint.isActive = true
            heightConstraint = constraint
        } else if let current = heightConstraint?.constant, abs(current - height) < 1 {
            return
        } else {
            heightConstraint?.constant = height
        }

        // Force layout updates throughout the hierarchy
        view.setNeedsLayout()
        view.layoutIfNeeded()
        inputView?.invalidateIntrinsicContentSize()
    }

    private func clearHeightConstraintIfNeeded() {
        if let constraint = heightConstraint {
            constraint.isActive = false
            heightConstraint = nil
        }
    }
}
