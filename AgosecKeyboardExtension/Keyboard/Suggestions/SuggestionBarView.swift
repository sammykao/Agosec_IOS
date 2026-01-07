import SwiftUI

struct SuggestionBarView: View {
    @State private var suggestions: [String] = []
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(suggestions, id: \\.self) { suggestion in
                    SuggestionButton(text: suggestion) {
                        // Handle suggestion tap
                    }
                }
                
                if suggestions.isEmpty {
                    Text("No suggestions")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct SuggestionButton: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 14))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(16)
        }
        .foregroundColor(.primary)
    }
}