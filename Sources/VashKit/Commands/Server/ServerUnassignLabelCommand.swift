import ArgumentParser
import Foundation
import VasHostingClient

public struct ServerUnassignLabelCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "unassign-label",
        abstract: "Unassign a label from a server."
    )

    @Argument(help: "Server hostname.")
    var hostname: String

    @Option(name: .long, help: "Label name.")
    var label: String

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.unassignLabelFromServer(
            path: .init(serverHostname: hostname),
            body: .json(.init(name: label))
        )
        switch response {
        case .noContent:
            OutputFormatter.printSuccess("Label '\(label)' unassigned from '\(hostname)'.", format: clientOptions.format)
        case .notFound(let err):
            throw VashError.notFound((try? err.body.json.message) ?? "Server not found")
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
