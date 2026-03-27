import ArgumentParser
import Foundation
import VasHostingClient

public struct EmailForwardingCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "forwarding",
        abstract: "Configure email forwarding."
    )

    @Argument(help: "Domain name.")
    var domain: String

    @Argument(help: "Email account name (before @domain).")
    var email: String

    @Option(name: .long, help: "Comma-separated list of destination email addresses.")
    var emails: String

    @Flag(name: .long, help: "Delete original email after forwarding.")
    var deleteOriginal: Bool = false

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let destinations = emails.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let client = try clientOptions.makeClient()
        let response = try await client.setupEmailForwarding(
            path: .init(domain: domain, email: email),
            body: .json(.init(emails: destinations, deleteOriginalEmail: deleteOriginal))
        )
        switch response {
        case .noContent:
            OutputFormatter.printSuccess("Forwarding configured for '\(email)@\(domain)'.", format: clientOptions.format)
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
