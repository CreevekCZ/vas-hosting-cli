import ArgumentParser
import Foundation
import VasHostingClient

public struct DatabaseCreateCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a new database."
    )

    @Argument(help: "Domain name.")
    var domain: String

    @Option(name: .long, help: "Database name.")
    var name: String

    @Option(name: .long, help: "Database type.")
    var type: DatabaseType

    @Option(name: .long, help: "Database password (8-64 characters).")
    var password: String

    @Option(name: .long, help: "Character encoding (optional).")
    var encoding: String?

    @Option(name: .long, help: "Note (optional).")
    var note: String?

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func validate() throws {
        guard password.count >= 8, password.count <= 64 else {
            throw ValidationError("Password must be 8-64 characters.")
        }
    }

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.createDatabase(
            path: .init(domain: domain),
            body: .json(.init(
                name: name,
                _type: Components.Schemas.CreateDatabaseRequest._typePayload(rawValue: type.rawValue)!,
                password: password,
                encoding: encoding,
                note: note
            ))
        )
        switch response {
        case .noContent:
            OutputFormatter.printSuccess("Database '\(name)' created successfully.", format: clientOptions.format)
        case .conflict(let err):
            throw VashError.apiError((try? err.body.json.message) ?? "Database already exists")
        case .unprocessableContent(let err):
            throw VashError.apiError((try? err.body.json.message) ?? "Invalid parameters")
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
