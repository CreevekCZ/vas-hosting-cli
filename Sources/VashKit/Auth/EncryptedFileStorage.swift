#if !canImport(Security)
import Foundation
import Crypto

// Linux secure storage using AES-256-GCM encryption.
// The encryption key is derived from the machine ID, tying credentials to this machine.
public final class EncryptedFileStorage: SecureStorage, @unchecked Sendable {
    private let credentialsURL: URL
    private let salt = "vash.cz.vas-hosting.salt.v1"

    public init(credentialsDirectory: URL? = nil) {
        let dir = credentialsDirectory ?? EncryptedFileStorage.defaultDirectory()
        self.credentialsURL = dir.appendingPathComponent("credentials.enc")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    }

    public func store(key: String, value: String) throws {
        var credentials = try loadCredentials()
        credentials[key] = value
        try saveCredentials(credentials)
    }

    public func retrieve(key: String) throws -> String? {
        let credentials = try loadCredentials()
        return credentials[key]
    }

    public func delete(key: String) throws {
        var credentials = try loadCredentials()
        credentials.removeValue(forKey: key)
        try saveCredentials(credentials)
    }

    public func listKeys() throws -> [String] {
        let credentials = try loadCredentials()
        return Array(credentials.keys).sorted()
    }

    // MARK: - Private

    private static func defaultDirectory() -> URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home.appendingPathComponent(".vash")
    }

    private func encryptionKey() throws -> SymmetricKey {
        let machineID = try readMachineID()
        let keyMaterial = machineID + salt
        let hash = SHA256.hash(data: Data(keyMaterial.utf8))
        return SymmetricKey(data: hash)
    }

    private func readMachineID() throws -> String {
        let machineIDPath = "/etc/machine-id"
        if let id = try? String(contentsOfFile: machineIDPath, encoding: .utf8) {
            return id.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        // Fallback: use a stable identifier from /etc/hostname
        if let hostname = try? String(contentsOfFile: "/etc/hostname", encoding: .utf8) {
            return hostname.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        throw SecureStorageError.retrieveFailed("Cannot determine machine ID for encryption key")
    }

    private func loadCredentials() throws -> [String: String] {
        guard FileManager.default.fileExists(atPath: credentialsURL.path) else {
            return [:]
        }
        let encryptedData = try Data(contentsOf: credentialsURL)
        let key = try encryptionKey()
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        return try JSONDecoder().decode([String: String].self, from: decryptedData)
    }

    private func saveCredentials(_ credentials: [String: String]) throws {
        let key = try encryptionKey()
        let jsonData = try JSONEncoder().encode(credentials)
        let sealedBox = try AES.GCM.seal(jsonData, using: key)
        guard let combined = sealedBox.combined else {
            throw SecureStorageError.storeFailed("Failed to combine AES-GCM components")
        }
        try combined.write(to: credentialsURL, options: .atomic)
        // Restrict permissions to owner only
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o600],
            ofItemAtPath: credentialsURL.path
        )
    }
}
#endif
