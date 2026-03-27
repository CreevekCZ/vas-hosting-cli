import ArgumentParser
import Foundation

public struct AuthSwitchCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "switch",
        abstract: "Switch the current active account."
    )

    @Argument(help: "Account name to switch to.")
    var name: String

    public init() {}

    public func run() throws {
        let manager = AccountManager()
        try manager.switchAccount(to: name)
        print("Switched to account '\(name)'.")
    }
}
