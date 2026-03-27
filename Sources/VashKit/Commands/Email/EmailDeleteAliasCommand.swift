import ArgumentParser
import Foundation
import VasHostingClient

public struct EmailDeleteAliasCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "delete-alias",
        abstract: "Delete an email alias."
    )

    @Argument(help: "Domain name.")
    var domain: String

    @Argument(help: "Email account name (before @domain).")
    var email: String

    @Argument(help: "Alias name to delete.")
    var alias: String

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.deleteEmailAlias(
            path: .init(domain: domain, email: email, alias: alias)
        )
        switch response {
        case .noContent:
            OutputFormatter.printSuccess("Alias '\(alias)@\(domain)' deleted.", format: clientOptions.format)
        case .notFound(let err):
            throw VashError.notFound((try? err.body.json.message) ?? "Alias not found")
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
