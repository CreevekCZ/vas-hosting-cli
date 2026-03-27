import ArgumentParser
import Foundation
import VasHostingClient

public struct ServerLabelDeleteCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a server label (auto-unassigns from all servers)."
    )

    @Argument(help: "Label name.")
    var name: String

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.deleteServerLabel(path: .init(labelName: name))
        switch response {
        case .noContent:
            OutputFormatter.printSuccess("Label '\(name)' deleted.", format: clientOptions.format)
        case .notFound(let err):
            throw VashError.notFound((try? err.body.json.message) ?? "Label not found")
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
