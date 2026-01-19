import SwiftUI
import UIKit

struct TypingKeyboardView: View {
    let onAgentModeTapped: () -> Void
    let onKeyTapped: (Key) -> Void
    var onGlobeTapped: (() -> Void)?
    
    @State private var isShiftEnabled = false
    @State private var isSymbolMode = false
    
    var body: some View {
        VStack(spacing: 0) {
            SuggestionBarView()
                .frame(height: 44)
                .background(Color.gray.opacity(0.1))
            
            keyboardGrid
                .padding(.bottom, 8)
        }
        .background(Color(UIColor.systemBackground))
    }
    
    private var keyboardGrid: some View {
        VStack(spacing: 6) {
            ForEach(keyboardLayout.rows, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(row, id: \.id) { key in
                        if key.type == .globe {
                            GlobeKeyView(key: key, onTap: {
                                onGlobeTapped?()
                            })
                        } else {
                            KeyView(key: key) {
                                handleKeyPress(key)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }
    
    private var keyboardLayout: KeyboardLayout {
        if isSymbolMode {
            return SymbolKeyboardLayout()
        } else {
            return QWERTYKeyboardLayout(isShiftEnabled: isShiftEnabled)
        }
    }
    
    private func handleKeyPress(_ key: Key) {
        switch key.type {
        case .shift:
            isShiftEnabled.toggle()
        case .symbol:
            isSymbolMode.toggle()
        case .globe:
            // Handled separately by GlobeKeyView
            break
        default:
            onKeyTapped(key)
            if isShiftEnabled && key.type == .character {
                isShiftEnabled = false
            }
        }
    }
}

// Special view for globe key that uses UIKit for proper keyboard switching
struct GlobeKeyView: UIViewRepresentable {
    let key: Key
    let onTap: () -> Void
    
    func makeUIView(context: Context) -> GlobeButton {
        let button = GlobeButton(onTap: onTap)
        return button
    }
    
    func updateUIView(_ uiView: GlobeButton, context: Context) {}
}

class GlobeButton: UIButton {
    private let onTap: () -> Void
    
    init(onTap: @escaping () -> Void) {
        self.onTap = onTap
        super.init(frame: .zero)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        // Appearance
        backgroundColor = UIColor.systemGray5
        layer.cornerRadius = 4
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor
        
        // Globe icon
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        let image = UIImage(systemName: "globe", withConfiguration: config)
        setImage(image, for: .normal)
        tintColor = .label
        
        // Size
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 32),
            heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Tap action
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
    
    @objc private func handleTap() {
        onTap()
    }
}

struct KeyView: View {
    let key: Key
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                keyContent
            }
        }
        .frame(height: keyHeight)
        .frame(width: keyWidth)
    }
    
    private var keyContent: some View {
        Group {
            if let imageName = key.imageName {
                Image(systemName: imageName)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
            } else {
                Text(key.displayValue)
                    .font(.system(size: keyFontSize, weight: keyWeight))
                    .foregroundColor(.primary)
            }
        }
    }
    
    private var keyHeight: CGFloat {
        switch key.size {
        case .normal: 44
        case .wide: 44
        case .space: 44
        }
    }
    
    private var keyWidth: CGFloat {
        let baseWidth: CGFloat = 32
        let screenWidth = UIScreen.main.bounds.width
        
        switch key.size {
        case .normal:
            return baseWidth
        case .wide:
            return baseWidth * 1.5
        case .space:
            return screenWidth * 0.4
        }
    }
    
    private var keyFontSize: CGFloat {
        switch key.size {
        case .normal, .wide:
            return 18
        case .space:
            return 16
        }
    }
    
    private var keyWeight: Font.Weight {
        switch key.type {
        case .character:
            return .regular
        default:
            return .medium
        }
    }
}