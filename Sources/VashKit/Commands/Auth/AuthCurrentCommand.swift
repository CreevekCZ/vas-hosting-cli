import ArgumentParser
import Foundation

public struct AuthCurrentCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "current",
        abstract: "Show the current active account."
    )

    public init() {}

    public func run() throws {
        let manager = AccountManager()
        guard let current = try manager.currentAccountName() else {
            print("No current account set. Run 'vash auth login' to add one.")
            return
        }
        print(current)
    }
}
