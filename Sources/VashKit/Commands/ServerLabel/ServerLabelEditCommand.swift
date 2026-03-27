import ArgumentParser
import Foundation
import VasHostingClient

public struct ServerLabelEditCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "edit",
        abstract: "Edit a server label."
    )

    @Argument(help: "Current label name.")
    var name: String

    @Option(name: .long, help: "New label name (no whitespace).")
    var newName: String?

    @Option(name: .long, help: "New color in hex format.")
    var color: String?

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func validate() throws {
        guard newName != nil || color != nil else {
            throw ValidationError("Specify at least --new-name or --color.")
        }
    }

    public func run() async throws {
        let effectiveName = newName ?? name
        let client = try clientOptions.makeClient()
        let response = try await client.editServerLabel(
            path: .init(labelName: name),
            body: .json(.init(name: effectiveName, color: color))
        )
        switch response {
        case .noContent:
            OutputFormatter.printSuccess("Label '\(name)' updated.", format: clientOptions.format)
        case .notFound(let err):
            throw VashError.notFound((try? err.body.json.message) ?? "Label not found")
        case .unprocessableContent(let err):
            throw VashError.apiError((try? err.body.json.message) ?? "Invalid parameters")
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
