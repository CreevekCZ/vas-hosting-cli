import Foundation

public protocol SecureStorage: Sendable {
    func store(key: String, value: String) throws
    func retrieve(key: String) throws -> String?
    func delete(key: String) throws
    func listKeys() throws -> [String]
}

public enum SecureStorageError: LocalizedError {
    case storeFailed(String)
    case retrieveFailed(String)
    case deleteFailed(String)
    case keyNotFound(String)

    public var errorDescription: String? {
        switch self {
        case .storeFailed(let msg): return "Failed to store credential: \(msg)"
        case .retrieveFailed(let msg): return "Failed to retrieve credential: \(msg)"
        case .deleteFailed(let msg): return "Failed to delete credential: \(msg)"
        case .keyNotFound(let key): return "Credential not found for key: \(key)"
        }
    }
}

public func makeSecureStorage() -> SecureStorage {
    #if canImport(Security)
    return KeychainStorage()
    #else
    return EncryptedFileStorage()
    #endif
}
