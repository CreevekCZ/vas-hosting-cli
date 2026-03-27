import ArgumentParser
import Foundation
import VasHostingClient

public struct ServerRebootCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "reboot",
        abstract: "Reboot a server."
    )

    @Argument(help: "Server hostname.")
    var hostname: String

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.rebootServer(path: .init(serverHostname: hostname))
        switch response {
        case .noContent:
            OutputFormatter.printSuccess("Reboot initiated for '\(hostname)'.", format: clientOptions.format)
        case .unauthorized(let err):
            throw VashError.unauthorized((try? err.body.json.message) ?? "Insufficient permissions.")
        case .notFound(let err):
            throw VashError.notFound((try? err.body.json.message) ?? "Server not found")
        case .undocumented(let statusCode, _):
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
