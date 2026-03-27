import ArgumentParser
import Foundation

public struct AuthListCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List all configured accounts."
    )

    @Option(name: .long, help: "Output format: table or json.")
    var format: OutputFormat = .table

    public init() {}

    public func run() throws {
        let manager = AccountManager()
        let accounts = try manager.listAccounts()
        let currentName = try manager.currentAccountName()

        switch format {
        case .table:
            if accounts.isEmpty {
                print("No accounts configured. Run 'vash auth login' to add one.")
                return
            }
            OutputFormatter.printTable(
                headers: ["NAME", "CURRENT"],
                rows: accounts.map { account in
                    [account.name, account.name == currentName ? "*" : ""]
                }
            )
        case .json:
            let result = accounts.map { account in
                ["name": account.name, "current": account.name == currentName ? "true" : "false"]
            }
            OutputFormatter.printJSON(result)
        }
    }
}
