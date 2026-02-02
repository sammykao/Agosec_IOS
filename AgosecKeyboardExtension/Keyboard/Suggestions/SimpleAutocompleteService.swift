import Foundation
import KeyboardKit
import SymSpellSwift

final class SimpleAutocompleteService: AutocompleteService {
    var locale: Locale = .current
    var canIgnoreWords: Bool { false }
    var canLearnWords: Bool { false }
    var ignoredWords: [String] { [] }
    var learnedWords: [String] { [] }

    private static let dictionaryTermCount = 25000
    private let symSpell = SymSpell(maxDictionaryEditDistance: 2, prefixLength: 3)
    private var hasLoadedDictionary = false
    private var loadTask: Task<Void, Never>?
    private var bigramCounts: [String: Int] = [:]
    private var bigramIndex: [String: [(word: String, count: Int)]] = [:]

    func autocomplete(_ text: String) async throws -> Autocomplete.Result {
        await ensureDictionaryLoaded()

        let token = currentWord(in: text)
        let previousWord = previousWord(in: text)
        let contextWord = token.isEmpty ? lastWord(in: text) : previousWord
        if token.count < 2 {
            let nextFromBigram = topBigrams(for: contextWord, prefix: nil)
            if !nextFromBigram.isEmpty {
                return Autocomplete.Result(
                    inputText: text,
                    suggestions: nextFromBigram.prefix(3).map { Autocomplete.Suggestion(text: $0) }
                )
            }
            return Autocomplete.Result(
                inputText: text,
                suggestions: defaultSuggestions().map { Autocomplete.Suggestion(text: $0) }
            )
        }

        let lowered = token.lowercased()
        let typoMatches = smartReplacements(for: lowered)
        let compoundMatches = symSpell
            .lookupCompound(text)
            .compactMap { item in
                lastWord(in: item.term)
            }
        let contextualMatches = contextualSuggestions(previousWord: previousWord, token: lowered)
        let bigramNextMatches = topBigrams(for: contextWord, prefix: lowered)
        let suggestions = (typoMatches + contextualMatches + bigramNextMatches + compoundMatches)
            .uniqued()
        let ranked = rankSuggestions(suggestions, previousWord: previousWord)
            .prefix(3)
            .map { Autocomplete.Suggestion(text: $0) }

        return Autocomplete.Result(
            inputText: text,
            suggestions: Array(ranked)
        )
    }

    private func currentWord(in text: String) -> String {
        guard let last = text.last, !last.isWhitespace else {
            return ""
        }

        var start = text.endIndex
        while start > text.startIndex {
            let prev = text.index(before: start)
            if text[prev].isWhitespace {
                break
            }
            start = prev
        }
        return String(text[start..<text.endIndex])
    }

    private func previousWord(in text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let parts = trimmed.split(whereSeparator: { $0.isWhitespace })
        guard parts.count >= 2 else { return nil }
        return normalizeWord(String(parts[parts.count - 2]))
    }

    private func lastWord(in text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        guard let last = trimmed.split(whereSeparator: { $0.isWhitespace }).last else { return nil }
        return normalizeWord(String(last))
    }

    private func normalizeWord(_ word: String) -> String? {
        let letters = word.lowercased().filter { $0.isLetter }
        return letters.isEmpty ? nil : letters
    }

    private func smartReplacements(for token: String) -> [String] {
        switch token {
        case "im": return ["I'm"]
        case "dont": return ["don't"]
        case "cant": return ["can't"]
        case "wont": return ["won't"]
        case "idk": return ["I don't know"]
        case "ive": return ["I've"]
        case "ill": return ["I'll"]
        case "didnt": return ["didn't"]
        case "isnt": return ["isn't"]
        case "youre": return ["you're"]
        case "theyre": return ["they're"]
        case "weve": return ["we've"]
        case "lets": return ["let's"]
        default: return []
        }
    }

    private func defaultSuggestions() -> [String] {
        ["the", "and", "you"]
    }

    private func contextualSuggestions(previousWord: String?, token: String) -> [String] {
        guard let previousWord = previousWord?.lowercased() else { return [] }

        switch previousWord {
        case "i":
            return ["am", "have", "will"]
        case "you":
            return ["are", "can", "will"]
        case "we":
            return ["are", "can", "will"]
        case "they":
            return ["are", "have", "will"]
        case "to":
            return ["be", "have", "go"]
        case "for":
            return ["the", "your", "a"]
        case "in":
            return ["the", "a", "this"]
        case "on":
            return ["the", "a", "this"]
        case "with":
            return ["the", "your", "a"]
        default:
            return []
        }
    }

    private func ensureDictionaryLoaded() async {
        guard !hasLoadedDictionary else { return }
        if let task = loadTask {
            await task.value
            return
        }

        let task = Task { [weak self] in
            guard let self = self else { return }
            guard let url = Bundle.main.url(
                forResource: "autocomplete_en_small",
                withExtension: "txt"
            ) else { return }
            try? await self.symSpell.loadDictionary(
                from: url,
                termIndex: 0,
                countIndex: 1,
                termCount: Self.dictionaryTermCount
            )
            if let bigramUrl = Bundle.main.url(
                forResource: "bigrams_en_small",
                withExtension: "txt"
            ) {
                try? await self.symSpell.loadBigramDictionary(
                    from: bigramUrl,
                    termIndex: 0,
                    countIndex: 2,
                    termCount: 15000
                )
                let bigrams = self.loadBigrams(from: bigramUrl)
                self.bigramCounts = bigrams
                self.bigramIndex = self.buildBigramIndex(from: bigrams)
            }
            self.hasLoadedDictionary = true
        }
        loadTask = task
        await task.value
    }

    private func loadBigrams(from url: URL) -> [String: Int] {
        guard let content = try? String(contentsOf: url, encoding: .utf8) else { return [:] }
        var result: [String: Int] = [:]
        for line in content.split(separator: "\n") {
            let parts = line.split(separator: " ")
            if parts.count < 3 { continue }
            let key = "\(parts[0].lowercased()) \(parts[1].lowercased())"
            if let count = Int(parts[2]) {
                result[key] = count
            }
        }
        return result
    }

    private func buildBigramIndex(from bigrams: [String: Int]) -> [String: [(word: String, count: Int)]] {
        var index: [String: [(word: String, count: Int)]] = [:]
        for (key, count) in bigrams {
            let parts = key.split(separator: " ")
            guard parts.count == 2 else { continue }
            let first = String(parts[0])
            let second = String(parts[1])
            index[first, default: []].append((word: second, count: count))
        }
        for (first, list) in index {
            index[first] = list.sorted { $0.count > $1.count }
        }
        return index
    }

    private func topBigrams(for previousWord: String?, prefix: String?) -> [String] {
        guard let previousWord = previousWord?.lowercased() else { return [] }
        guard let list = bigramIndex[previousWord] else { return [] }
        if let prefix = prefix, !prefix.isEmpty {
            return list.compactMap { item in
                item.word.hasPrefix(prefix) ? item.word : nil
            }
        }
        return list.map { $0.word }
    }

    private func rankSuggestions(_ suggestions: [String], previousWord: String?) -> [String] {
        guard let previousWord = previousWord?.lowercased() else { return suggestions }
        return suggestions.sorted { lhs, rhs in
            let leftKey = "\(previousWord) \(lhs.lowercased())"
            let rightKey = "\(previousWord) \(rhs.lowercased())"
            let leftScore = bigramCounts[leftKey] ?? 0
            let rightScore = bigramCounts[rightKey] ?? 0
            if leftScore == rightScore { return lhs < rhs }
            return leftScore > rightScore
        }
    }
}

extension SimpleAutocompleteService {
    func hasIgnoredWord(_ word: String) -> Bool { false }
    func hasLearnedWord(_ word: String) -> Bool { false }
    func ignoreWord(_ word: String) {}
    func learnWord(_ word: String) {}
    func removeIgnoredWord(_ word: String) {}
    func unlearnWord(_ word: String) {}
}

private extension Array where Element == String {
    func uniqued() -> [String] {
        var seen = Set<String>()
        return filter { seen.insert($0).inserted }
    }
}
