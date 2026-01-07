import UIKit
import SharedCore

class KeyboardHeightManager {
    private weak var view: UIView?
    
    init(view: UIView) {
        self.view = view
    }
    
    func calculateHeight(mode: KeyboardMode, isExpanded: Bool) -> CGFloat {
        guard let window = view?.window else { return 260 }
        
        let screenHeight = window.bounds.height
        let orientation = UIDevice.current.orientation
        
        switch mode {
        case .normal:
            return calculateNormalHeight(screenHeight: screenHeight, orientation: orientation)
        case .agent:
            return calculateAgentHeight(screenHeight: screenHeight, orientation: orientation)
        }
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
        let targetHeight = screenHeight * 0.80
        
        if orientation.isPortrait || orientation == .unknown {
            return clamp(targetHeight, min: 420, max: 650)
        } else {
            return clamp(targetHeight, min: 300, max: 420)
        }
    }
    
    private func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        return Swift.max(min, Swift.min(max, value))
    }
}