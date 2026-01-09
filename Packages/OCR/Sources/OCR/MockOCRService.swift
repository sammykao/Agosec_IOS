import Foundation
import UIKit
import SharedCore

/// Mock OCR service for UI testing without real image processing
public class MockOCRService: OCRServiceProtocol {
    
    public init() {}
    
    public func extractText(from images: [UIImage]) async throws -> ContextDoc {
        // Simulate OCR processing delay
        try await Task.sleep(nanoseconds: UInt64(BuildMode.mockNetworkDelay * 1_000_000_000))
        
        // Generate mock OCR text based on number of images
        let mockTexts: [String]
        
        switch images.count {
        case 1:
            mockTexts = [
                "Sample conversation about lunch plans with friends discussing where to meet and what to eat.",
                "Meeting notes from team standup discussing project timeline and upcoming deadlines.",
                "Email thread about vacation planning and dates for the upcoming holiday season.",
                "Text message conversation about weekend plans and activities.",
                "Screenshot of a recipe with ingredients and cooking instructions."
            ]
        case 2:
            mockTexts = [
                "First screenshot: Conversation about lunch plans\n\nSecond screenshot: Restaurant recommendations and reviews",
                "Screenshot 1: Meeting agenda\n\nScreenshot 2: Action items and follow-ups",
                "Image 1: Email about project status\n\nImage 2: Response with updates and questions"
            ]
        default:
            mockTexts = [
                "Multiple screenshots containing various conversations and notes about different topics.",
                "Collection of images with text about plans, meetings, and communications.",
                "Screenshots showing conversations, emails, and messages across different contexts."
            ]
        }
        
        let rawText = mockTexts.randomElement() ?? "Mock OCR text extracted from \(images.count) screenshot(s)"
        
        // Generate a simple summary
        let summary = generateSummary(from: rawText)
        
        // Trim to max context chars if needed
        let config = Config.shared
        let trimmedText = String(rawText.prefix(config.featureFlags.maxContextChars))
        
        return ContextDoc(
            rawText: trimmedText,
            summary: summary
        )
    }
    
    private func generateSummary(from text: String) -> String {
        let lowercased = text.lowercased()
        
        if lowercased.contains("lunch") || lowercased.contains("food") || lowercased.contains("restaurant") {
            return "Conversation about lunch plans and restaurant selection"
        } else if lowercased.contains("meeting") || lowercased.contains("standup") || lowercased.contains("agenda") {
            return "Meeting notes and discussion about project timeline"
        } else if lowercased.contains("email") || lowercased.contains("message") {
            return "Email thread or message conversation"
        } else if lowercased.contains("vacation") || lowercased.contains("holiday") || lowercased.contains("travel") {
            return "Planning discussion about vacation or travel"
        } else if lowercased.contains("recipe") || lowercased.contains("cooking") || lowercased.contains("ingredients") {
            return "Recipe or cooking instructions"
        } else {
            return "Context extracted from screenshots"
        }
    }
}

