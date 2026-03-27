import ArgumentParser
import Foundation
import VasHostingClient

public struct InfrastructureListOsCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "list-os",
        abstract: "List operating systems available for server installation."
    )

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.listOperatingSystems()
        switch response {
        case .ok(let ok):
            let body = try ok.body.json
            switch clientOptions.format {
            case .table:
                let rows = body.additionalProperties
                    .map { id, os in [id, os.name, os.distribution] }
                    .sorted { $0[0] < $1[0] }
                OutputFormatter.printTable(headers: ["ID", "NAME", "DISTRIBUTION"], rows: rows)
            case .json:
                OutputFormatter.printJSON(body)
            }
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
