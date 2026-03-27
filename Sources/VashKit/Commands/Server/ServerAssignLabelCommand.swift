import ArgumentParser
import Foundation
import VasHostingClient

public struct ServerAssignLabelCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "assign-label",
        abstract: "Assign a label to a server."
    )

    @Argument(help: "Server hostname.")
    var hostname: String

    @Option(name: .long, help: "Label name.")
    var label: String

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.assignLabelToServer(
            path: .init(serverHostname: hostname),
            body: .json(.init(label: label))
        )
        switch response {
        case .noContent:
            OutputFormatter.printSuccess("Label '\(label)' assigned to '\(hostname)'.", format: clientOptions.format)
        case .notModified:
            OutputFormatter.printSuccess("Label '\(label)' already assigned to '\(hostname)'.", format: clientOptions.format)
        case .badRequest(let err):
            throw VashError.apiError((try? err.body.json.message) ?? "Label not found")
        case .notFound(let err):
            throw VashError.notFound((try? err.body.json.message) ?? "Server not found")
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
