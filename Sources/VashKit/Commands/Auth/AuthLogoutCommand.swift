import ArgumentParser
import Foundation

public struct AuthLogoutCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "logout",
        abstract: "Remove an account and its stored API key."
    )

    @Argument(help: "Account name to remove.",
              completion: .custom { _, _, _ in AccountManager.savedAccountNames() })
    var name: String

    public init() {}

    public func run() throws {
        let manager = AccountManager()
        try manager.removeAccount(name: name)
        print("Account '\(name)' removed.")
    }
}
