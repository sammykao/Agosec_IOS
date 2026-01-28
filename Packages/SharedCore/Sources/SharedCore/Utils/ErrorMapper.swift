import Foundation

/// Maps API errors to user-friendly messages
public struct ErrorMapper {
    private static let httpStatusMessages: [Int: String] = [
        400: "Bad request (400). The request was malformed. Please try again or contact support.",
        401: "Unauthorized (401). Please sign in again or check your subscription status.",
        403: "Forbidden (403). You don't have permission to access this resource. Please check your subscription.",
        404: "Resource not found (404). The requested endpoint doesn't exist. Please try again or contact support.",
        408: "Request timeout (408). The server took too long to respond. Please try again.",
        429: "Too many requests (429). You've exceeded the rate limit. Please wait a moment and try again.",
        500: "Internal server error (500). Our servers are experiencing issues. Please try again in a few moments.",
        502: "Bad gateway (502). The server is temporarily unavailable. Please try again in a few moments.",
        503: "Service unavailable (503). The service is temporarily down for maintenance. Please try again later.",
        504: "Gateway timeout (504). The server took too long to respond. Please try again."
    ]
    private static let urlErrorMessages: [Int: String] = [
        NSURLErrorNotConnectedToInternet: "No internet connection. Please check your Wi-Fi or cellular data " +
            "and try again.",
        NSURLErrorTimedOut: "Request timed out. The server took too long to respond. Please check your " +
            "connection and try again.",
        NSURLErrorCannotFindHost: "Cannot reach server. The hostname cannot be found. Please check your " +
            "internet connection.",
        NSURLErrorCannotConnectToHost: "Cannot connect to server. The server may be down or unreachable. " +
            "Please try again in a few moments.",
        NSURLErrorNetworkConnectionLost: "Network connection was lost. Please check your connection and try again.",
        NSURLErrorDNSLookupFailed: "DNS lookup failed. Cannot resolve the server address. Please check your " +
            "internet connection.",
        NSURLErrorHTTPTooManyRedirects: "Too many redirects. The server configuration may be incorrect. " +
            "Please contact support.",
        NSURLErrorResourceUnavailable: "Resource unavailable. The requested resource is not available. " +
            "Please try again later.",
        NSURLErrorBadServerResponse: "Invalid server response. The server returned unexpected data. " +
            "Please try again.",
        NSURLErrorUserCancelledAuthentication: "Authentication was cancelled. Please try again and complete " +
            "the authentication process.",
        NSURLErrorUserAuthenticationRequired: "Authentication required. Please sign in and try again.",
        NSURLErrorSecureConnectionFailed: "Secure connection failed. There may be an issue with the server's " +
            "security certificate. Please try again or contact support."
    ]

    /// Converts an Error to a user-friendly message
    public static func userFriendlyMessage(from error: Error) -> String {
        // Handle errors that provide their own user-facing copy
        if let presentable = error as? UserPresentableError {
            return presentable.userMessage
        }

        // Handle APIError
        if let apiError = error as? APIError {
            return message(for: apiError)
        }

        // Handle OCRError
        if let ocrError = error as? OCRError {
            return message(for: ocrError)
        }

        // Handle NSError with detailed information
        if let nsError = error as NSError? {
            return message(for: nsError)
        }

        // Extract detailed information from any error
        return detailedMessage(for: error)
    }

    /// Determines if an error should show a retry button
    public static func shouldShowRetry(for error: Error) -> Bool {
        if let presentable = error as? UserPresentableError {
            return presentable.isRetryable
        }

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

        // For unknown errors, check if it's a network-related error
        if let nsError = error as NSError? {
            let domain = nsError.domain
            let code = nsError.code

            // Network-related NSError codes
            if domain == NSURLErrorDomain {
                return true // Most URL errors are retryable
            }

            // POSIX errors (network-related)
            if domain == NSPOSIXErrorDomain && (code == 50 || code == 51 || code == 61 || code == 64) {
                return true
            }
        }

        return false
    }

    private static func message(for error: APIError) -> String {
        switch error {
        case .networkError(let underlyingError):
            let underlyingMessage = extractUnderlyingErrorMessage(from: underlyingError)
            if !underlyingMessage.isEmpty {
                return "Network connection failed: \(underlyingMessage)." +
                    " Please check your internet connection and try again."
            }
            return "Network connection failed. Please check your internet connection and try again."

        case .unauthorized:
            return "Your session has expired or you're not authorized." +
                " Please sign in again or check your subscription status."

        case .serverError(let message):
            return "Server error occurred: \(message). Our servers may be experiencing issues." +
                " Please try again in a few moments."

        case .invalidResponse:
            return "Received an invalid response from the server. This may be a temporary issue. Please try again."

        case .decodingError(let underlyingError):
            let underlyingMessage = extractUnderlyingErrorMessage(from: underlyingError)
            if !underlyingMessage.isEmpty {
                return "Failed to process server response: \(underlyingMessage)." +
                    " Please try again or contact support if this persists."
            }
            return "Failed to process server response. The data format may have changed." +
                " Please try again or contact support."

        case .invalidURL:
            return "Invalid request URL. This appears to be a configuration issue. Please contact support."

        case .httpError(let code):
            return httpErrorMessage(for: code)
        }
    }

    private static func httpErrorMessage(for code: Int) -> String {
        if let message = httpStatusMessages[code] {
            return message
        }

        if code >= 500 {
            return "Server error (\(code)). Our servers are experiencing issues. Please try again in a few moments."
        }
        if code >= 400 {
            return "Client error (\(code)). There was a problem with your request. Please try again or contact support."
        }
        return "HTTP error (\(code)). Please try again."
    }

    private static func message(for error: OCRError) -> String {
        switch error {
        case .invalidImage:
            return "Invalid image format. Please select a valid screenshot or photo." +
                " Supported formats: PNG, JPEG, HEIC."

        case .visionError(let underlyingError):
            let underlyingMessage = extractUnderlyingErrorMessage(from: underlyingError)
            if !underlyingMessage.isEmpty {
                return "Failed to extract text from image: \(underlyingMessage)." +
                    " Please try with a clearer image or different screenshot."
            }
            return "Failed to extract text from image. The image may be too blurry, low quality," +
                " or contain no readable text. Please try with a clearer screenshot."

        case .noTextFound:
            return "No text was found in the selected image. Please choose a screenshot that contains visible text," +
                " or continue without context."
        }
    }

    private static func message(for error: NSError) -> String {
        let domain = error.domain
        let code = error.code
        let description = error.localizedDescription
        let failureReason = error.localizedFailureReason ?? ""
        let recoverySuggestion = error.localizedRecoverySuggestion ?? ""

        var message = "An error occurred"

        // Handle specific error domains
        switch domain {
        case NSURLErrorDomain:
            message = urlErrorMessage(for: code, description: description)

        case NSPOSIXErrorDomain:
            message = posixErrorMessage(for: code, description: description)

        case NSCocoaErrorDomain:
            message = cocoaErrorMessage(for: code, description: description)

        default:
            // Use the error's description if available
            if !description.isEmpty && description != "The operation couldn't be completed." {
                message = description
            } else {
                message = "Error in domain '\(domain)' (code \(code))"
            }
        }

        // Add failure reason if available
        if !failureReason.isEmpty {
            message += ". \(failureReason)"
        }

        // Add recovery suggestion if available
        if !recoverySuggestion.isEmpty {
            message += " \(recoverySuggestion)"
        } else {
            message += " Please try again."
        }

        return message
    }

    private static func urlErrorMessage(for code: Int, description: String) -> String {
        if let message = urlErrorMessages[code] {
            return message
        }
        if !description.isEmpty {
            return "Network error: \(description). Please check your connection and try again."
        }
        return "Network error (code \(code)). Please check your internet connection and try again."
    }

    private static func posixErrorMessage(for code: Int, description: String) -> String {
        switch code {
        case 50: // ENETDOWN
            return "Network is down. Please check your connection and try again."
        case 51: // ENETUNREACH
            return "Network is unreachable. Please check your connection and try again."
        case 61: // ECONNREFUSED
            return "Connection refused by server. The server may be down. Please try again later."
        case 64: // EHOSTDOWN
            return "Host is down. The server is not responding. Please try again later."
        default:
            if !description.isEmpty {
                return "System error: \(description). Please try again."
            }
            return "System error (code \(code)). Please try again."
        }
    }

    private static func cocoaErrorMessage(for code: Int, description: String) -> String {
        switch code {
        case 3840: // NSPropertyListReadCorruptError
            return "Data corruption detected. The received data is corrupted. Please try again."
        case 3841: // NSPropertyListReadUnknownVersionError
            return "Unknown data format version. The app may need to be updated. Please try updating the app."
        default:
            if !description.isEmpty {
                return "Data error: \(description). Please try again."
            }
            return "Data processing error (code \(code)). Please try again."
        }
    }

    private static func detailedMessage(for error: Error) -> String {
        let errorType = String(describing: type(of: error))
        let errorDescription = error.localizedDescription

        var message = "An unexpected error occurred"

        // Try to extract useful information
        if !errorDescription.isEmpty && errorDescription != "The operation couldn't be completed." {
            message = errorDescription
        } else {
            message = "Error type: \(errorType)"
        }

        message += ". Please try again. If this problem persists, contact support and mention error type: \(errorType)"

        // Add underlying error info if available
        if let nsError = error as NSError? {
            let domain = nsError.domain
            let code = nsError.code
            if domain != "NSCocoaErrorDomain" && domain != "NSURLErrorDomain" {
                message += " (Domain: \(domain), Code: \(code))"
            }
        }

        return message
    }

    private static func extractUnderlyingErrorMessage(from error: Error?) -> String {
        guard let error = error else { return "" }

        let description = error.localizedDescription
        if !description.isEmpty && description != "The operation couldn't be completed." {
            return description
        }

        if let nsError = error as NSError? {
            if let failureReason = nsError.localizedFailureReason, !failureReason.isEmpty {
                return failureReason
            }
        }

        return ""
    }
}
