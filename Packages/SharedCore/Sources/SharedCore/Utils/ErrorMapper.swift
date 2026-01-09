import Foundation
import Networking

/// Maps API errors to user-friendly messages
public struct ErrorMapper {
    
    /// Converts an Error to a user-friendly message
    public static func userFriendlyMessage(from error: Error) -> String {
        if let apiError = error as? APIError {
            return message(for: apiError)
        }
        
        // Handle other error types
        if let ocrError = error as? OCRError {
            return message(for: ocrError)
        }
        
        // Generic fallback
        return "Something went wrong. Please try again."
    }
    
    /// Determines if an error should show a retry button
    public static func shouldShowRetry(for error: Error) -> Bool {
        if let apiError = error as? APIError {
            switch apiError {
            case .networkError, .serverError, .invalidResponse:
                return true
            case .unauthorized, .invalidURL, .decodingError, .httpError:
                return false
            }
        }
        
        if let ocrError = error as? OCRError {
            switch ocrError {
            case .visionError, .invalidImage:
                return true
            case .noTextFound:
                return false
            }
        }
        
        return false
    }
    
    private static func message(for error: APIError) -> String {
        switch error {
        case .networkError:
            return "Connection failed. Check your internet and try again."
        case .unauthorized:
            return "Session expired. Please sign in again."
        case .serverError(let message):
            return "Server error: \(message). Please try again later."
        case .invalidResponse:
            return "Invalid response from server. Please try again."
        case .decodingError:
            return "Failed to process response. Please try again."
        case .invalidURL:
            return "Invalid request. Please contact support."
        case .httpError(let code):
            if code == 404 {
                return "Resource not found. Please try again."
            } else if code >= 500 {
                return "Server error. Please try again later."
            } else {
                return "Request failed. Please try again."
            }
        }
    }
    
    private static func message(for error: OCRError) -> String {
        switch error {
        case .invalidImage:
            return "Invalid image. Please select a different screenshot."
        case .visionError:
            return "Failed to read text from image. Please try again."
        case .noTextFound:
            return "No text found in image. Please try a different screenshot."
        }
    }
}

