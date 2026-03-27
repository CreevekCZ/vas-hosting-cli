import ArgumentParser
import Foundation
import VasHostingClient

public struct DatabaseListCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List databases for a domain."
    )

    @Argument(help: "Domain name.")
    var domain: String

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.listDatabases(path: .init(domain: domain))
        switch response {
        case .ok(let ok):
            let body = try ok.body.json
            switch clientOptions.format {
            case .table:
                let rows = body.additionalProperties
                    .map { name, db in [name, db.user, db._type.rawValue, "\(db.size) MB"] }
                    .sorted { $0[0] < $1[0] }
                OutputFormatter.printTable(headers: ["NAME", "USER", "TYPE", "SIZE"], rows: rows)
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
