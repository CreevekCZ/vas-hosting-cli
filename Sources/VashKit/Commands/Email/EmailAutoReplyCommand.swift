import ArgumentParser
import Foundation
import VasHostingClient

public struct EmailAutoReplyCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "auto-reply",
        abstract: "Configure auto-reply for an email account."
    )

    @Argument(help: "Domain name.")
    var domain: String

    @Argument(help: "Email account name (before @domain).")
    var email: String

    @Flag(name: .long, help: "Enable auto-reply.")
    var enable: Bool = false

    @Flag(name: .long, help: "Disable auto-reply.")
    var disable: Bool = false

    @Option(name: .long, help: "Auto-active from datetime (YYYY-MM-DD HH:MM:SS).")
    var from: String?

    @Option(name: .long, help: "Auto-active to datetime (YYYY-MM-DD HH:MM:SS).")
    var to: String?

    @Option(name: .long, help: "Email subject.")
    var subject: String?

    @Option(name: .long, help: "Email body content.")
    var content: String?

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func validate() throws {
        guard enable || disable else {
            throw ValidationError("Specify either --enable or --disable.")
        }
        guard !(enable && disable) else {
            throw ValidationError("Cannot specify both --enable and --disable.")
        }
    }

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.setupEmailAutoReply(
            path: .init(domain: domain, email: email),
            body: .json(.init(
                isActive: enable,
                autoActiveFrom: from,
                autoActiveTo: to,
                subject: subject,
                content: content
            ))
        )
        switch response {
        case .noContent:
            let state = enable ? "enabled" : "disabled"
            OutputFormatter.printSuccess("Auto-reply \(state) for '\(email)@\(domain)'.", format: clientOptions.format)
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
