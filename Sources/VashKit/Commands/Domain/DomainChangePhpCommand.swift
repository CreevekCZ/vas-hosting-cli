import ArgumentParser
import Foundation
import VasHostingClient

public struct DomainChangePhpCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "change-php",
        abstract: "Change PHP version for a domain."
    )

    @Argument(help: "Domain name.")
    var domain: String

    @Option(name: .long, help: "PHP version (e.g., 8.2, 8.3).")
    var version: String

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.changeDomainPhpVersion(
            path: .init(domain: domain),
            body: .json(.init(version: version))
        )
        switch response {
        case .noContent:
            OutputFormatter.printSuccess("PHP version changed to \(version) for \(domain).", format: clientOptions.format)
        case .unauthorized(let err):
            throw VashError.unauthorized((try? err.body.json.message) ?? "Unauthorized. Check your API key.")
        case .unprocessableContent(let err):
            throw VashError.apiError((try? err.body.json.message) ?? "Invalid PHP version")
        case .undocumented(let statusCode, _):
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
