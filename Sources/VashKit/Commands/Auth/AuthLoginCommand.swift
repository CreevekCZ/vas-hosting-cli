import ArgumentParser
import Foundation

public struct AuthLoginCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "login",
        abstract: "Add a vas-hosting.cz account with its API key."
    )

    @Option(name: .long, help: "Account name (e.g., personal, work).")
    var name: String

    @Option(name: .long, help: "API key from https://portal.vas-hosting.cz/api-key")
    var apiKey: String

    public init() {}

    public func run() throws {
        let manager = AccountManager()
        try manager.addAccount(name: name, apiKey: apiKey)
        print("Account '\(name)' added successfully.")
        let current = try manager.currentAccountName()
        if current == name {
            print("Set as the current account.")
        }
    }
}
