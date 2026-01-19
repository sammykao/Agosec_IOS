import UIKit

/// Service for providing autocomplete suggestions using iOS's built-in text checking
class AutocompleteService {
    private let textChecker = UITextChecker()
    private let maxSuggestions = 3
    
    /// Get the language code for text checking (defaults to English)
    private var languageCode: String {
        guard let preferred = NSLocale.preferredLanguages.first else { return "en" }
        let code = String(preferred.prefix(2))
        return code.lowercased()
    }
    
    /// Get autocomplete suggestions for the current word being typed
    /// - Parameters:
    ///   - text: The full text in the text field
    ///   - selectedRange: The current cursor position
    /// - Returns: Array of suggestion strings
    func getSuggestions(for text: String, selectedRange: NSRange) -> [String] {
        guard !text.isEmpty else { return [] }
        
        // Find the current word being typed
        let wordRange = findCurrentWordRange(in: text, at: selectedRange.location)
        guard wordRange.location != NSNotFound else { return [] }
        
        let word = (text as NSString).substring(with: wordRange)
        
        // Don't suggest for very short words or if word is complete
        guard word.count >= 2 else { return [] }
        
        // Get completions from UITextChecker
        let completions = textChecker.completions(
            forPartialWordRange: wordRange,
            in: text,
            language: languageCode
        ) ?? []
        
        // Filter and limit suggestions
        let filtered = completions
            .filter { $0.lowercased().hasPrefix(word.lowercased()) }
            .filter { $0 != word } // Don't suggest the same word
            .prefix(maxSuggestions)
        
        return Array(filtered)
    }
    
    /// Get autocorrect suggestions for a misspelled word
    /// - Parameters:
    ///   - text: The full text
    ///   - wordRange: Range of the word to check
    /// - Returns: Array of correction suggestions
    func getCorrections(for text: String, wordRange: NSRange) -> [String] {
        guard wordRange.location != NSNotFound else { return [] }
        
        let misspelledRange = textChecker.rangeOfMisspelledWord(
            in: text,
            range: wordRange,
            startingAt: 0,
            wrap: false,
            language: languageCode
        )
        
        guard misspelledRange.location != NSNotFound else { return [] }
        
        let guesses = textChecker.guesses(
            forWordRange: misspelledRange,
            in: text,
            language: languageCode
        ) ?? []
        
        return Array(guesses.prefix(maxSuggestions))
    }
    
    /// Find the range of the current word being typed
    func findCurrentWordRange(in text: String, at location: Int) -> NSRange {
        let nsString = text as NSString
        let searchRange = NSRange(location: 0, length: min(location, nsString.length))
        
        // Find word boundaries
        let options: NSString.EnumerationOptions = [.byWords, .localized]
        var wordRange = NSRange(location: NSNotFound, length: 0)
        
        nsString.enumerateSubstrings(
            in: searchRange,
            options: options
        ) { substring, range, _, stop in
            if NSLocationInRange(location - 1, range) || location == range.location + range.length {
                wordRange = range
                stop.pointee = true
            }
        }
        
        // If no word found, check if we're at the start of a new word
        if wordRange.location == NSNotFound && location < nsString.length {
            let charSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
            let char = nsString.character(at: location)
            
            if !charSet.contains(UnicodeScalar(char)!) {
                // We're in a word, find its boundaries
                var start = location
                var end = location
                
                // Find start
                while start > 0 {
                    let char = nsString.character(at: start - 1)
                    if charSet.contains(UnicodeScalar(char)!) {
                        break
                    }
                    start -= 1
                }
                
                // Find end
                while end < nsString.length {
                    let char = nsString.character(at: end)
                    if charSet.contains(UnicodeScalar(char)!) {
                        break
                    }
                    end += 1
                }
                
                wordRange = NSRange(location: start, length: end - start)
            }
        }
        
        return wordRange
    }
    
    /// Get suggestions based on context (previous words)
    func getContextualSuggestions(for text: String, selectedRange: NSRange) -> [String] {
        // This could be enhanced with ML or custom dictionary
        // For now, use basic word completion
        return getSuggestions(for: text, selectedRange: selectedRange)
    }
}
