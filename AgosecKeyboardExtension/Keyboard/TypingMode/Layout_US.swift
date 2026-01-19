import Foundation
import SwiftUI

struct Key: Identifiable, Hashable {
    let id = UUID()
    let value: String
    let type: KeyType
    let size: KeySize
    let displayValue: String
    let imageName: String?
    
    init(value: String, type: KeyType = .character, size: KeySize = .normal, displayValue: String? = nil, imageName: String? = nil) {
        self.value = value
        self.type = type
        self.size = size
        self.displayValue = displayValue ?? value
        self.imageName = imageName
    }
}

enum KeyType {
    case character
    case backspace
    case space
    case shift
    case symbol
    case `return`
    case arrow
    case emoji
}

enum KeySize {
    case normal      // Regular letter key
    case wide        // Shift, backspace, 123, return
    case space       // Spacebar
    case functional  // Bottom row functional keys (123, emoji)
}

protocol KeyboardLayout {
    var rows: [[Key]] { get }
}

struct QWERTYKeyboardLayout: KeyboardLayout {
    let isShiftEnabled: Bool
    
    var rows: [[Key]] {
        return [
            // Row 1: QWERTYUIOP (10 keys)
            ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"].map {
                Key(value: caseValue($0))
            },
            
            // Row 2: ASDFGHJKL (9 keys - centered)
            ["a", "s", "d", "f", "g", "h", "j", "k", "l"].map {
                Key(value: caseValue($0))
            },
            
            // Row 3: Shift + ZXCVBNM + Backspace
            [
                Key(value: "", type: .shift, size: .wide, imageName: isShiftEnabled ? "shift.fill" : "shift"),
                Key(value: caseValue("z")),
                Key(value: caseValue("x")),
                Key(value: caseValue("c")),
                Key(value: caseValue("v")),
                Key(value: caseValue("b")),
                Key(value: caseValue("n")),
                Key(value: caseValue("m")),
                Key(value: "", type: .backspace, size: .wide, imageName: "delete.left")
            ],
            
            // Row 4: 123, Emoji, Space, Return
            [
                Key(value: "123", type: .symbol, size: .functional),
                Key(value: "😀", type: .emoji, size: .functional, displayValue: "😀"),
                Key(value: " ", type: .space, size: .space, displayValue: "space"),
                Key(value: "", type: .arrow, size: .functional, imageName: "return")
            ]
        ]
    }
    
    private func caseValue(_ char: String) -> String {
        return isShiftEnabled ? char.uppercased() : char.lowercased()
    }
}

struct SymbolKeyboardLayout: KeyboardLayout {
    var rows: [[Key]] {
        [
            // Row 1: Numbers
            ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"].map {
                Key(value: $0)
            },
            
            // Row 2: Symbols (9 keys - centered like letters)
            ["-", "/", ":", ";", "(", ")", "$", "&", "@"].map {
                Key(value: $0)
            },
            
            // Row 3
            [
                Key(value: "#+=", type: .symbol, size: .wide),
                Key(value: "."),
                Key(value: ","),
                Key(value: "?"),
                Key(value: "!"),
                Key(value: "'"),
                Key(value: "\""),
                Key(value: "", type: .backspace, size: .wide, imageName: "delete.left")
            ],
            
            // Row 4
            [
                Key(value: "ABC", type: .symbol, size: .functional),
                Key(value: "😀", type: .emoji, size: .functional, displayValue: "😀"),
                Key(value: " ", type: .space, size: .space, displayValue: "space"),
                Key(value: "", type: .arrow, size: .functional, imageName: "return")
            ]
        ]
    }
}
