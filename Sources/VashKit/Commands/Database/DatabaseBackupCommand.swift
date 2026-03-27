import ArgumentParser
import Foundation
import VasHostingClient

public struct DatabaseBackupCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "backup",
        abstract: "Trigger a database backup."
    )

    @Argument(help: "Domain name.")
    var domain: String

    @Argument(help: "Database name.")
    var database: String

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.backupDatabase(
            path: .init(domain: domain, database: database)
        )
        switch response {
        case .noContent:
            OutputFormatter.printSuccess("Backup triggered for database '\(database)'.", format: clientOptions.format)
        case .notFound(let err):
            throw VashError.notFound((try? err.body.json.message) ?? "Database not found")
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
