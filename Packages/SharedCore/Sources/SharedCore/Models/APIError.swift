import Foundation

/// Errors that can occur during API requests
public enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case unauthorized
    case serverError(String)
}
