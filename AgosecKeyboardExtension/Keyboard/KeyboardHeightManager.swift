import UIKit
import SharedCore

class KeyboardHeightManager {
    private weak var view: UIView?
    
    // Default heights for when window isn't available
    private let defaultNormalHeight: CGFloat = 260
    private let defaultAgentHeight: CGFloat = 500
    
    init(view: UIView) {
        self.view = view
    }
    
    func calculateHeight(mode: KeyboardMode, isExpanded: Bool) -> CGFloat {
        // ALWAYS use UIScreen.main.bounds.height for screen height
        // Don't use window or superview bounds as they may be the keyboard's current height
        let screenHeight = UIScreen.main.bounds.height
        
        print("📏 Screen height: \(screenHeight) (from UIScreen.main.bounds)")
        
        let orientation = UIDevice.current.orientation
        
        let height: CGFloat
        switch mode {
        case .normal:
            height = calculateNormalHeight(screenHeight: screenHeight, orientation: orientation)
        case .agent:
            height = calculateAgentHeight(screenHeight: screenHeight, orientation: orientation)
        }
        
        print("📏 KeyboardHeightManager - mode: \(mode), screenHeight: \(screenHeight), calculated height: \(height), percentage: \(Int((height/screenHeight)*100))%")
        return height
    }
    
    private func calculateNormalHeight(screenHeight: CGFloat, orientation: UIDeviceOrientation) -> CGFloat {
        let targetHeight = screenHeight * 0.32
        
        if orientation.isPortrait || orientation == .unknown {
            return clamp(targetHeight, min: 260, max: 360)
        } else {
            return clamp(targetHeight * 0.7, min: 200, max: 280)
        }
    }
    
    private func calculateAgentHeight(screenHeight: CGFloat, orientation: UIDeviceOrientation) -> CGFloat {
        // Use 80% of screen height for agent mode
        let height = screenHeight * 0.80
        print("📏 Agent height: \(height) (80% of \(screenHeight))")
        return height
    }
    
    private func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        return Swift.max(min, Swift.min(max, value))
    }
}