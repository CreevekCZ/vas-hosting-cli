import ArgumentParser
import Foundation
import VasHostingClient

public struct ServerLabelCreateCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a server label."
    )

    @Option(name: .long, help: "Label name (no whitespace).")
    var name: String

    @Option(name: .long, help: "Color in hex format (e.g., #ff0000).")
    var color: String?

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.createServerLabel(
            body: .json(.init(name: name, color: color))
        )
        switch response {
        case .noContent:
            OutputFormatter.printSuccess("Label '\(name)' created.", format: clientOptions.format)
        case .conflict(let err):
            throw VashError.apiError((try? err.body.json.message) ?? "Label already exists")
        case .unprocessableContent(let err):
            throw VashError.apiError((try? err.body.json.message) ?? "Invalid label name or color")
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
