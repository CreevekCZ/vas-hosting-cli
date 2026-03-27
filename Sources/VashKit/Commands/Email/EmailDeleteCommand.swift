import ArgumentParser
import Foundation
import VasHostingClient

public struct EmailDeleteCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete an email account."
    )

    @Argument(help: "Domain name.")
    var domain: String

    @Argument(help: "Email account name (before @domain).")
    var email: String

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.deleteEmailAccount(
            path: .init(domain: domain, email: email)
        )
        switch response {
        case .noContent:
            OutputFormatter.printSuccess("Email account '\(email)@\(domain)' deleted.", format: clientOptions.format)
        case .notFound(let err):
            throw VashError.notFound((try? err.body.json.message) ?? "Account not found")
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
