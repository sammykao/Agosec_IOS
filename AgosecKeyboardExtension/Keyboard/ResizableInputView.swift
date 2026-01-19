import UIKit

/// Custom UIInputView that supports dynamic height changes
class ResizableInputView: UIInputView {
    
    private var customHeight: CGFloat = 260
    
    override init(frame: CGRect, inputViewStyle: UIInputView.Style) {
        super.init(frame: frame, inputViewStyle: inputViewStyle)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
    }
    
    override var intrinsicContentSize: CGSize {
        let size = CGSize(width: UIView.noIntrinsicMetric, height: customHeight)
        print("📐 ResizableInputView intrinsicContentSize called - returning: \(size)")
        return size
    }
    
    override func invalidateIntrinsicContentSize() {
        super.invalidateIntrinsicContentSize()
        print("📐 ResizableInputView invalidateIntrinsicContentSize called")
    }
    
    func setHeight(_ height: CGFloat, animated: Bool = true) {
        print("📐 ResizableInputView setHeight called - from \(customHeight) to \(height)")
        guard abs(customHeight - height) > 1.0 else { 
            print("📐 Height unchanged (difference < 1pt), skipping")
            return 
        }
        
        customHeight = height
        
        // Always invalidate intrinsic content size - this is critical for keyboard extensions
        invalidateIntrinsicContentSize()
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut, .allowUserInteraction]) {
                // Force layout updates
                self.setNeedsLayout()
                self.layoutIfNeeded()
                
                // Update superview
                self.superview?.setNeedsLayout()
                self.superview?.layoutIfNeeded()
                
                // Update window if available
                if let window = self.window {
                    window.setNeedsLayout()
                    window.layoutIfNeeded()
                }
            } completion: { _ in
                // Ensure final state is correct
                self.invalidateIntrinsicContentSize()
            }
        } else {
            // Immediate update
            setNeedsLayout()
            layoutIfNeeded()
            superview?.setNeedsLayout()
            superview?.layoutIfNeeded()
            window?.setNeedsLayout()
            window?.layoutIfNeeded()
        }
    }
}
