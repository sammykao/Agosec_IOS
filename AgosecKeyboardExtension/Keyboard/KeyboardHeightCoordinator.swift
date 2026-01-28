import UIKit
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

    func syncConstraintIfNeeded(mode: KeyboardMode, isExpanded: Bool) {
        guard let view = view else { return }

        let currentCalculatedHeight = heightManager.calculateHeight(
            mode: mode,
            isExpanded: isExpanded
        )

        // Only update if the constraint doesn't match what it should be
        if abs(heightConstraint?.constant ?? 0 - currentCalculatedHeight) > 5 {
            heightConstraint?.constant = currentCalculatedHeight
            view.setNeedsLayout()
        }
    }

    func updateHeight(mode: KeyboardMode, isExpanded: Bool, inputView: UIView?) {
        guard let view = view else { return }
        guard !isUpdatingHeight else { return }
        isUpdatingHeight = true
        defer { isUpdatingHeight = false }

        let height = heightManager.calculateHeight(
            mode: mode,
            isExpanded: isExpanded
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

        // Also update the view's frame directly
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
}
