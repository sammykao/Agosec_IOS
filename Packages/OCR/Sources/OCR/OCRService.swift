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
        var extractedTexts: [String] = []
        extractedTexts.reserveCapacity(images.count)
        
        for (index, image) in images.enumerated() {
            let text = try await performOCR(on: image)
            extractedTexts.append("\n--- Screenshot \(index + 1) ---\n\(text)")
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
