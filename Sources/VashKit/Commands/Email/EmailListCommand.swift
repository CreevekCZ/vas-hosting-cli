import ArgumentParser
import Foundation
import VasHostingClient

public struct EmailListCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List email accounts for a domain."
    )

    @Argument(help: "Domain name.")
    var domain: String

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.listEmailAccounts(path: .init(domain: domain))
        switch response {
        case .ok(let ok):
            let body = try ok.body.json
            switch clientOptions.format {
            case .table:
                let rows = body.additionalProperties
                    .map { name, acct in
                        [name, acct.quota == 0 ? "Unlimited" : "\(acct.quota) MB",
                         acct.isActive ? "Active" : "Inactive",
                         acct.isAutoReply ? "Yes" : "No",
                        ]
                    }
                    .sorted { $0[0] < $1[0] }
                OutputFormatter.printTable(headers: ["NAME", "QUOTA", "STATUS", "AUTO-REPLY"], rows: rows)
            case .json:
                OutputFormatter.printJSON(body)
            }
        case .unauthorized(let err):
            throw VashError.unauthorized((try? err.body.json.message) ?? "Unauthorized. Check your API key.")
        case .undocumented(let statusCode, _):
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
