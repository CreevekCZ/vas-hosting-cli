import ArgumentParser
import Foundation
import VasHostingClient

public struct ServerListCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List all active servers."
    )

    @Option(name: .long, parsing: .upToNextOption, help: "Filter by label names.")
    var labels: [String] = []

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let labelQuery = labels.isEmpty ? nil : labels
        let response = try await client.listServers(.init(
            query: .init(labels_lbrack__rbrack_: labelQuery)
        ))
        switch response {
        case .ok(let ok):
            let body = try ok.body.json
            switch clientOptions.format {
            case .table:
                var rows: [[String]] = []
                for (hostname, server) in body.additionalProperties {
                    rows.append([
                        hostname,
                        server.name,
                        server.status,
                        server.tariff,
                        server.expiration,
                        server.labels?.joined(separator: ",") ?? "",
                    ])
                }
                rows.sort { $0[0] < $1[0] }
                OutputFormatter.printTable(
                    headers: ["HOSTNAME", "NAME", "STATUS", "TARIFF", "EXPIRATION", "LABELS"],
                    rows: rows
                )
            case .json:
                OutputFormatter.printJSON(body)
            }
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
