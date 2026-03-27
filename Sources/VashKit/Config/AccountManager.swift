import Foundation

public enum AccountError: LocalizedError, Equatable {
    case noCurrentAccount
    case accountNotFound(String)
    case accountAlreadyExists(String)
    case apiKeyNotFound(String)

    public var errorDescription: String? {
        switch self {
        case .noCurrentAccount:
            return "No active account. Run 'vash auth login' to add an account."
        case .accountNotFound(let name):
            return "Account '\(name)' not found."
        case .accountAlreadyExists(let name):
            return "Account '\(name)' already exists."
        case .apiKeyNotFound(let name):
            return "API key not found for account '\(name)'."
        }
    }
}

public final class AccountManager: @unchecked Sendable {
    private let configURL: URL
    private let storage: SecureStorage

    public init(configDirectory: URL? = nil, storage: SecureStorage? = nil) {
        let dir = configDirectory ?? AccountManager.defaultDirectory()
        self.configURL = dir.appendingPathComponent("config.json")
        self.storage = storage ?? makeSecureStorage()
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    }

    // MARK: - Account CRUD

    public func addAccount(name: String, apiKey: String) throws {
        var config = try loadConfig()
        guard !config.accounts.contains(where: { $0.name == name }) else {
            throw AccountError.accountAlreadyExists(name)
        }
        try storage.store(key: storageKey(for: name), value: apiKey)
        config.accounts.append(AccountEntry(name: name))
        if config.currentAccount == nil {
            config.currentAccount = name
        }
        try saveConfig(config)
    }

    public func removeAccount(name: String) throws {
        var config = try loadConfig()
        guard config.accounts.contains(where: { $0.name == name }) else {
            throw AccountError.accountNotFound(name)
        }
        try storage.delete(key: storageKey(for: name))
        config.accounts.removeAll { $0.name == name }
        if config.currentAccount == name {
            config.currentAccount = config.accounts.first?.name
        }
        try saveConfig(config)
    }

    public func listAccounts() throws -> [AccountEntry] {
        return try loadConfig().accounts
    }

    public func currentAccountName() throws -> String? {
        return try loadConfig().currentAccount
    }

    public func switchAccount(to name: String) throws {
        var config = try loadConfig()
        guard config.accounts.contains(where: { $0.name == name }) else {
            throw AccountError.accountNotFound(name)
        }
        config.currentAccount = name
        try saveConfig(config)
    }

    // MARK: - API Key Resolution

    public func apiKey(for accountName: String? = nil) throws -> String {
        let config = try loadConfig()
        let name: String
        if let override = accountName {
            guard config.accounts.contains(where: { $0.name == override }) else {
                throw AccountError.accountNotFound(override)
            }
            name = override
        } else {
            guard let current = config.currentAccount else {
                throw AccountError.noCurrentAccount
            }
            name = current
        }
        guard let key = try storage.retrieve(key: storageKey(for: name)) else {
            throw AccountError.apiKeyNotFound(name)
        }
        return key
    }

    // MARK: - Shell Completion Support

    /// Returns all saved account names synchronously — used by shell completion callbacks.
    public static func savedAccountNames() -> [String] {
        let configURL = defaultDirectory().appendingPathComponent("config.json")
        guard
            let data = try? Data(contentsOf: configURL),
            let config = try? JSONDecoder().decode(AccountConfig.self, from: data)
        else { return [] }
        return config.accounts.map(\.name)
    }

    // MARK: - Private

    private static func defaultDirectory() -> URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home.appendingPathComponent(".vash")
    }

    private func storageKey(for accountName: String) -> String {
        return "vash.account.\(accountName)"
    }

    private func loadConfig() throws -> AccountConfig {
        guard FileManager.default.fileExists(atPath: configURL.path) else {
            return AccountConfig()
        }
        let data = try Data(contentsOf: configURL)
        return try JSONDecoder().decode(AccountConfig.self, from: data)
    }

    private func saveConfig(_ config: AccountConfig) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(config)
        try data.write(to: configURL, options: .atomic)
    }
}
