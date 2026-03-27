import ArgumentParser
import Foundation
import VasHostingClient

public struct EmailCreateCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create an email account."
    )

    @Argument(help: "Domain name.")
    var domain: String

    @Option(name: .long, help: "Account name (before @domain).")
    var name: String

    @Option(name: .long, help: "Display name.")
    var displayName: String

    @Option(name: .long, help: "Password (8-64 characters).")
    var password: String

    @Option(name: .long, help: "Quota in MB (0 for unlimited).")
    var quota: Int = 0

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.createEmailAccount(
            path: .init(domain: domain),
            body: .json(.init(name: name, displayName: displayName, password: password, quota: quota))
        )
        switch response {
        case .noContent:
            OutputFormatter.printSuccess("Email account '\(name)@\(domain)' created.", format: clientOptions.format)
        case .conflict(let err):
            throw VashError.apiError((try? err.body.json.message) ?? "Account already exists")
        case .unprocessableContent(let err):
            throw VashError.apiError((try? err.body.json.message) ?? "Invalid parameters")
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
