import ArgumentParser
import Foundation
import VasHostingClient

public struct ServerLabelListCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List all server labels."
    )

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.listServerLabels()
        switch response {
        case .ok(let ok):
            let body = try ok.body.json
            switch clientOptions.format {
            case .table:
                let rows = body.additionalProperties
                    .map { name, label in [name, label.color] }
                    .sorted { $0[0] < $1[0] }
                OutputFormatter.printTable(headers: ["NAME", "COLOR"], rows: rows)
            case .json:
                OutputFormatter.printJSON(body)
            }
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
