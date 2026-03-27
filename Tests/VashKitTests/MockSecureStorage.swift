@testable import VashKit
import Foundation

final class MockSecureStorage: SecureStorage {
    var stored: [String: String] = [:]

    func store(key: String, value: String) throws {
        stored[key] = value
    }

    func retrieve(key: String) throws -> String? {
        return stored[key]
    }

    func delete(key: String) throws {
        stored.removeValue(forKey: key)
    }

    func listKeys() throws -> [String] {
        return Array(stored.keys).sorted()
    }
}
