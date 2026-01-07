import Foundation
import Vision
import UIKit
import SharedCore

public protocol OCRServiceProtocol {
    func extractText(from images: [UIImage]) async throws -> ContextDoc
}

public class OCRService: OCRServiceProtocol {
    
    public init() {}
    
    public func extractText(from images: [UIImage]) async throws -> ContextDoc {
        let extractedTexts = try await withThrowingTaskGroup(of: String.self) { group in
            for (index, image) in images.enumerated() {
                group.addTask {
                    let text = try await self.performOCR(on: image)
                    return "\n--- Screenshot \(index + 1) ---\n\(text)"
                }
            }
            
            var results: [String] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }
        
        let combinedText = extractedTexts.joined(separator: "\n")
        let trimmedText = trimToMaxLength(combinedText, maxLength: Config.shared.featureFlags.maxContextChars)
        
        return ContextDoc(rawText: trimmedText)
    }
    
    private func performOCR(on image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw OCRError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: OCRError.visionError(error))
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: OCRError.noTextFound)
                    return
                }
                
                let text = observations.compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")
                
                continuation.resume(returning: text)
            }
            
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: OCRError.visionError(error))
            }
        }
    }
    
    private func trimToMaxLength(_ text: String, maxLength: Int) -> String {
        if text.count <= maxLength {
            return text
        }
        
        let endIndex = text.index(text.startIndex, offsetBy: maxLength)
        return String(text[..<endIndex])
    }
}

public enum OCRError: Error {
    case invalidImage
    case visionError(Error)
    case noTextFound
}