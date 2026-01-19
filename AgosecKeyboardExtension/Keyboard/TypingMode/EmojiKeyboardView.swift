import SwiftUI

struct EmojiKeyboardView: View {
    let onEmojiSelected: (String) -> Void
    let onBackToAlphabet: () -> Void
    
    @State private var selectedCategory: EmojiCategory = .frequentlyUsed
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Category bar
            categoryBar
            
            // Emoji grid
            emojiGrid
                .frame(maxHeight: .infinity)
            
            // Bottom row with back button
            bottomRow
        }
        .background(Color.clear)
    }
    
    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(EmojiCategory.allCases, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        Image(systemName: category.iconName)
                            .font(.system(size: 20))
                            .foregroundColor(selectedCategory == category ? .blue : .gray)
                            .frame(width: 44, height: 44)
                            .background(
                                selectedCategory == category ?
                                Color.blue.opacity(0.1) : Color.clear
                            )
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(height: 44)
        .background(Color.clear)
    }
    
    private var emojiGrid: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 8), spacing: 0) {
                ForEach(emojisForCategory, id: \.self) { emoji in
                    Button(action: {
                        onEmojiSelected(emoji)
                    }) {
                        Text(emoji)
                            .font(.system(size: 32))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 8)
        }
    }
    
    private var bottomRow: some View {
        HStack(spacing: 6) {
            // Globe button (for switching keyboards)
            Button(action: {}) {
                Image(systemName: "globe")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
            }
            .frame(maxWidth: .infinity)
            
            // Space bar
            Button(action: {
                onEmojiSelected(" ")
            }) {
                Text("space")
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .frame(maxWidth: .infinity)
            
            // Return button
            Button(action: {
                onEmojiSelected("\n")
            }) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 18))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 3)
        .padding(.vertical, 8)
    }
    
    private var emojisForCategory: [String] {
        switch selectedCategory {
        case .frequentlyUsed:
            return EmojiData.frequentlyUsed
        case .smileys:
            return EmojiData.smileys
        case .people:
            return EmojiData.people
        case .animals:
            return EmojiData.animals
        case .food:
            return EmojiData.food
        case .travel:
            return EmojiData.travel
        case .activities:
            return EmojiData.activities
        case .objects:
            return EmojiData.objects
        case .symbols:
            return EmojiData.symbols
        case .flags:
            return EmojiData.flags
        }
    }
    
}

enum EmojiCategory: CaseIterable {
    case frequentlyUsed
    case smileys
    case people
    case animals
    case food
    case travel
    case activities
    case objects
    case symbols
    case flags
    
    var iconName: String {
        switch self {
        case .frequentlyUsed: return "clock.fill"
        case .smileys: return "face.smiling"
        case .people: return "person.2.fill"
        case .animals: return "pawprint.fill"
        case .food: return "leaf.fill"
        case .travel: return "airplane"
        case .activities: return "sportscourt.fill"
        case .objects: return "lightbulb.fill"
        case .symbols: return "number"
        case .flags: return "flag.fill"
        }
    }
}

struct EmojiData {
    static let frequentlyUsed: [String] = [
        "😀", "😂", "❤️", "😍", "😊", "👍", "😭", "🙏", "😘", "🥰",
        "😎", "🤔", "😴", "😋", "🤗", "😱", "😇", "🤩", "😏", "😌"
    ]
    
    static let smileys: [String] = [
        "😀", "😃", "😄", "😁", "😆", "😅", "🤣", "😂", "🙂", "🙃",
        "😉", "😊", "😇", "🥰", "😍", "🤩", "😘", "😗", "☺️", "😚",
        "😙", "😋", "😛", "😜", "🤪", "😝", "🤑", "🤗", "🤭", "🤫",
        "🤔", "🤐", "🤨", "😐", "😑", "😶", "😏", "😒", "🙄", "😬",
        "🤥", "😌", "😔", "😪", "🤤", "😴", "😷", "🤒", "🤕", "🤢"
    ]
    
    static let people: [String] = [
        "👶", "👧", "🧒", "👦", "👩", "🧑", "👨", "👵", "🧓", "👴",
        "👮", "👷", "💂", "🕵️", "👩‍⚕️", "👨‍⚕️", "👩‍🌾", "👨‍🌾", "👩‍🍳", "👨‍🍳",
        "👩‍🎓", "👨‍🎓", "👩‍🎤", "👨‍🎤", "👩‍🏫", "👨‍🏫", "👩‍🏭", "👨‍🏭", "👩‍💻", "👨‍💻"
    ]
    
    static let animals: [String] = [
        "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯",
        "🦁", "🐮", "🐷", "🐽", "🐸", "🐵", "🙈", "🙉", "🙊", "🐒",
        "🐔", "🐧", "🐦", "🐤", "🐣", "🐥", "🦆", "🦅", "🦉", "🦇"
    ]
    
    static let food: [String] = [
        "🍏", "🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🍈",
        "🍒", "🍑", "🥭", "🍍", "🥥", "🥝", "🍅", "🍆", "🥑", "🥦",
        "🥬", "🥒", "🌶️", "🌽", "🥕", "🥔", "🍠", "🥐", "🥯", "🍞"
    ]
    
    static let travel: [String] = [
        "🚗", "🚕", "🚙", "🚌", "🚎", "🏎️", "🚓", "🚑", "🚒", "🚐",
        "🚚", "🚛", "🚜", "🛴", "🚲", "🛵", "🏍️", "🛺", "🚨", "🚔",
        "✈️", "🛫", "🛬", "🛩️", "💺", "🚀", "🚁", "🚤", "⛵", "🛥️"
    ]
    
    static let activities: [String] = [
        "⚽", "🏀", "🏈", "⚾", "🥎", "🎾", "🏐", "🏉", "🥏", "🎱",
        "🏓", "🏸", "🥅", "🏒", "🏑", "🏏", "🏑", "🏏", "🥊", "🥋",
        "🎽", "🛹", "🛷", "⛸️", "🥌", "🎿", "⛷️", "🏂", "🏋️", "🤼"
    ]
    
    static let objects: [String] = [
        "⌚", "📱", "📲", "💻", "⌨️", "🖥️", "🖨️", "🖱️", "🖲️", "🕹️",
        "🗜️", "💾", "💿", "📀", "📼", "📷", "📸", "📹", "🎥", "📽️",
        "🎞️", "📞", "☎️", "📟", "📠", "📺", "📻", "🎙️", "🎚️", "🎛️"
    ]
    
    static let symbols: [String] = [
        "❤️", "🧡", "💛", "💚", "💙", "💜", "🖤", "🤍", "🤎", "💔",
        "❣️", "💕", "💞", "💓", "💗", "💖", "💘", "💝", "💟", "☮️",
        "✝️", "☪️", "🕉️", "☸️", "✡️", "🔯", "🕎", "☯️", "☦️", "🛐"
    ]
    
    static let flags: [String] = [
        "🏳️", "🏴", "🏁", "🚩", "🏳️‍🌈", "🏳️‍⚧️", "🇺🇸", "🇬🇧", "🇨🇦", "🇦🇺",
        "🇩🇪", "🇫🇷", "🇮🇹", "🇪🇸", "🇯🇵", "🇨🇳", "🇮🇳", "🇧🇷", "🇷🇺", "🇰🇷"
    ]
}
