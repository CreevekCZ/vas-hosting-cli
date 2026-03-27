import ArgumentParser
import Foundation
import VasHostingClient

public struct EmailCreateAliasCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "create-alias",
        abstract: "Create an email alias."
    )

    @Argument(help: "Domain name.")
    var domain: String

    @Argument(help: "Email account name (before @domain).")
    var email: String

    @Option(name: .long, help: "Alias name.")
    var name: String

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.createEmailAlias(
            path: .init(domain: domain, email: email),
            body: .json(.init(name: name))
        )
        switch response {
        case .noContent:
            OutputFormatter.printSuccess("Alias '\(name)@\(domain)' created for '\(email)@\(domain)'.", format: clientOptions.format)
        case .unprocessableContent(let err):
            throw VashError.apiError((try? err.body.json.message) ?? "Invalid alias name")
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
