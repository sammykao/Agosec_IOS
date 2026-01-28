import Foundation

public enum ServiceFactoryError: Error {
    case missingAccessToken(service: String)
}
