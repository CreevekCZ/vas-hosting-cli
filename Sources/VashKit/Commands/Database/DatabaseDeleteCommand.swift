import ArgumentParser
import Foundation
import VasHostingClient

public struct DatabaseDeleteCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a database."
    )

    @Argument(help: "Domain name.")
    var domain: String

    @Argument(help: "Database name.")
    var database: String

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.deleteDatabase(
            path: .init(domain: domain, database: database)
        )
        switch response {
        case .noContent:
            OutputFormatter.printSuccess("Database '\(database)' deleted.", format: clientOptions.format)
        case .notFound(let err):
            throw VashError.notFound((try? err.body.json.message) ?? "Database not found")
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
