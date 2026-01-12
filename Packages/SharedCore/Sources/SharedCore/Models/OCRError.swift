import Foundation

/// Errors that can occur during OCR operations
public enum OCRError: Error {
    case invalidImage
    case visionError(Error)
    case noTextFound
}
