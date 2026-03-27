import Foundation

public enum VashError: LocalizedError {
    case unauthorized(String)
    case notFound(String)
    case apiError(String)
    case unexpectedStatus(Int)

    public var errorCode: String {
        switch self {
        case .unauthorized: return "unauthorized"
        case .notFound: return "not_found"
        case .apiError: return "api_error"
        case .unexpectedStatus: return "unexpected_status"
        }
    }

    public var errorDescription: String? {
        switch self {
        case .unauthorized(let message):
            return message
        case .notFound(let message):
            return message
        case .apiError(let message):
            return message
        case .unexpectedStatus(let code):
            return "Unexpected HTTP status: \(code)"
        }
    }
}
