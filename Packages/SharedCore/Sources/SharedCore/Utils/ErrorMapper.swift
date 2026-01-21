import Foundation

/// Maps API errors to user-friendly messages
public struct ErrorMapper {
    
    /// Converts an Error to a user-friendly message
    public static func userFriendlyMessage(from error: Error) -> String {
        // Handle APIError
        if let apiError = error as? APIError {
            return message(for: apiError)
        }
        
        // Handle OCRError
        if let ocrError = error as? OCRError {
            return message(for: ocrError)
        }
        
        // Handle AgentError and ChatError by checking type name
        let errorTypeName = String(describing: type(of: error))
        if errorTypeName.contains("AgentError") {
            return message(forAgentError: error)
        }
        
        if errorTypeName.contains("ChatError") {
            return message(forChatError: error)
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
        
        // AgentError and ChatError - check by type name
        let errorTypeName = String(describing: type(of: error))
        if errorTypeName.contains("AgentError") {
            // Check error description for specific cases
            let description = error.localizedDescription.lowercased()
            if description.contains("noapiaccess") || description.contains("no api access") {
                return false // User needs to authenticate/subscribe
            }
            return true // Other agent errors can be retried
        }
        
        if errorTypeName.contains("ChatError") {
            let description = error.localizedDescription.lowercased()
            if description.contains("noapiaccess") || description.contains("no api access") {
                return false // User needs to authenticate/subscribe
            }
            return true // Network errors can be retried
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
                return "Network connection failed: \(underlyingMessage). Please check your internet connection and try again."
            }
            return "Network connection failed. Please check your internet connection and try again."
            
        case .unauthorized:
            return "Your session has expired or you're not authorized. Please sign in again or check your subscription status."
            
        case .serverError(let message):
            return "Server error occurred: \(message). Our servers may be experiencing issues. Please try again in a few moments."
            
        case .invalidResponse:
            return "Received an invalid response from the server. This may be a temporary issue. Please try again."
            
        case .decodingError(let underlyingError):
            let underlyingMessage = extractUnderlyingErrorMessage(from: underlyingError)
            if !underlyingMessage.isEmpty {
                return "Failed to process server response: \(underlyingMessage). Please try again or contact support if this persists."
            }
            return "Failed to process server response. The data format may have changed. Please try again or contact support."
            
        case .invalidURL:
            return "Invalid request URL. This appears to be a configuration issue. Please contact support."
            
        case .httpError(let code):
            switch code {
            case 400:
                return "Bad request (400). The request was malformed. Please try again or contact support."
            case 401:
                return "Unauthorized (401). Please sign in again or check your subscription status."
            case 403:
                return "Forbidden (403). You don't have permission to access this resource. Please check your subscription."
            case 404:
                return "Resource not found (404). The requested endpoint doesn't exist. Please try again or contact support."
            case 408:
                return "Request timeout (408). The server took too long to respond. Please try again."
            case 429:
                return "Too many requests (429). You've exceeded the rate limit. Please wait a moment and try again."
            case 500:
                return "Internal server error (500). Our servers are experiencing issues. Please try again in a few moments."
            case 502:
                return "Bad gateway (502). The server is temporarily unavailable. Please try again in a few moments."
            case 503:
                return "Service unavailable (503). The service is temporarily down for maintenance. Please try again later."
            case 504:
                return "Gateway timeout (504). The server took too long to respond. Please try again."
            default:
                if code >= 500 {
                    return "Server error (\(code)). Our servers are experiencing issues. Please try again in a few moments."
                } else if code >= 400 {
                    return "Client error (\(code)). There was a problem with your request. Please try again or contact support."
                } else {
                    return "HTTP error (\(code)). Please try again."
                }
            }
        }
    }
    
    private static func message(for error: OCRError) -> String {
        switch error {
        case .invalidImage:
            return "Invalid image format. Please select a valid screenshot or photo. Supported formats: PNG, JPEG, HEIC."
            
        case .visionError(let underlyingError):
            let underlyingMessage = extractUnderlyingErrorMessage(from: underlyingError)
            if !underlyingMessage.isEmpty {
                return "Failed to extract text from image: \(underlyingMessage). Please try with a clearer image or different screenshot."
            }
            return "Failed to extract text from image. The image may be too blurry, low quality, or contain no readable text. Please try with a clearer screenshot."
            
        case .noTextFound:
            return "No text was found in the selected image. Please choose a screenshot that contains visible text, or continue without context."
        }
    }
    
    private static func message(forAgentError error: Error) -> String {
        let description = error.localizedDescription.lowercased()
        let errorString = String(describing: error).lowercased()
        
        if description.contains("noapiaccess") || errorString.contains("noapiaccess") || 
           description.contains("no api access") || errorString.contains("no api access") {
            return "API access is not available. This usually means you need to authenticate or have an active subscription. Please check your account status in the main app, or sign in again."
        }
        
        if description.contains("invalidcontext") || errorString.contains("invalidcontext") ||
           description.contains("invalid context") || errorString.contains("invalid context") {
            return "Invalid context provided. The context data may be corrupted or in an unsupported format. Please try again with a fresh session or different screenshots."
        }
        
        // Generic agent error
        let detailedDesc = error.localizedDescription
        if !detailedDesc.isEmpty && detailedDesc != "The operation couldn't be completed." {
            return "Agent error: \(detailedDesc). Please try again or contact support if this persists."
        }
        
        return "An error occurred while initializing the agent session. Please try again. If this problem continues, try restarting the keyboard or contact support."
    }
    
    private static func message(forChatError error: Error) -> String {
        let description = error.localizedDescription.lowercased()
        let errorString = String(describing: error).lowercased()
        
        if description.contains("noapiaccess") || errorString.contains("noapiaaccess") ||
           description.contains("no api access") || errorString.contains("no api access") {
            return "Chat API access is not available. Please ensure you're signed in and have an active subscription, then try again. You can check your subscription status in the main app."
        }
        
        if description.contains("network") || errorString.contains("network") {
            return "Network error occurred while sending your message. Please check your internet connection and try again."
        }
        
        // Generic chat error
        let detailedDesc = error.localizedDescription
        if !detailedDesc.isEmpty && detailedDesc != "The operation couldn't be completed." {
            return "Chat error: \(detailedDesc). Please try again."
        }
        
        return "An error occurred while processing your chat message. Please check your connection and try again."
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
        switch code {
        case NSURLErrorNotConnectedToInternet:
            return "No internet connection. Please check your Wi-Fi or cellular data and try again."
        case NSURLErrorTimedOut:
            return "Request timed out. The server took too long to respond. Please check your connection and try again."
        case NSURLErrorCannotFindHost:
            return "Cannot reach server. The hostname cannot be found. Please check your internet connection."
        case NSURLErrorCannotConnectToHost:
            return "Cannot connect to server. The server may be down or unreachable. Please try again in a few moments."
        case NSURLErrorNetworkConnectionLost:
            return "Network connection was lost. Please check your connection and try again."
        case NSURLErrorDNSLookupFailed:
            return "DNS lookup failed. Cannot resolve the server address. Please check your internet connection."
        case NSURLErrorHTTPTooManyRedirects:
            return "Too many redirects. The server configuration may be incorrect. Please contact support."
        case NSURLErrorResourceUnavailable:
            return "Resource unavailable. The requested resource is not available. Please try again later."
        case NSURLErrorBadServerResponse:
            return "Invalid server response. The server returned unexpected data. Please try again."
        case NSURLErrorUserCancelledAuthentication:
            return "Authentication was cancelled. Please try again and complete the authentication process."
        case NSURLErrorUserAuthenticationRequired:
            return "Authentication required. Please sign in and try again."
        case NSURLErrorSecureConnectionFailed:
            return "Secure connection failed. There may be an issue with the server's security certificate. Please try again or contact support."
        default:
            if !description.isEmpty {
                return "Network error: \(description). Please check your connection and try again."
            }
            return "Network error (code \(code)). Please check your internet connection and try again."
        }
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
        
        // Add context for common error patterns
        if errorType.contains("AgentError") {
            message += ". This appears to be related to agent session initialization. Please try again or contact support if this persists."
        } else if errorType.contains("ChatError") {
            message += ". This appears to be related to chat functionality. Please check your connection and try again."
        } else if errorType.contains("API") || errorType.contains("Network") {
            message += ". This appears to be a network or API issue. Please check your connection and try again."
        } else {
            message += ". Please try again. If this problem persists, contact support and mention error type: \(errorType)"
        }
        
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
