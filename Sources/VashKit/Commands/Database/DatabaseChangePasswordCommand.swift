import ArgumentParser
import Foundation
import VasHostingClient

public struct DatabaseChangePasswordCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "change-password",
        abstract: "Change the password of a database user."
    )

    @Argument(help: "Domain name.")
    var domain: String

    @Argument(help: "Database name.")
    var database: String

    @Option(name: .long, help: "New password (8-64 characters).")
    var password: String

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.changeDatabasePassword(
            path: .init(domain: domain, database: database),
            body: .json(.init(password: password))
        )
        switch response {
        case .noContent:
            OutputFormatter.printSuccess("Password changed for database '\(database)'.", format: clientOptions.format)
        case .unprocessableContent(let err):
            throw VashError.apiError((try? err.body.json.message) ?? "Invalid password")
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
