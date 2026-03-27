import Foundation

public struct AccountEntry: Codable, Equatable, Sendable {
    public let name: String

    public init(name: String) {
        self.name = name
    }
}

public struct AccountConfig: Codable, Sendable {
    public var currentAccount: String?
    public var accounts: [AccountEntry]

    public init(currentAccount: String? = nil, accounts: [AccountEntry] = []) {
        self.currentAccount = currentAccount
        self.accounts = accounts
    }
}
