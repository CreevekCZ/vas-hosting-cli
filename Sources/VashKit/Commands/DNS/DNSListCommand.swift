import ArgumentParser
import Foundation
import VasHostingClient

public struct DNSListCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List DNS records for a domain."
    )

    @Argument(help: "Domain name.")
    var domain: String

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.listDnsRecords(path: .init(domain: domain))
        switch response {
        case .ok(let ok):
            let body = try ok.body.json
            switch clientOptions.format {
            case .table:
                let rows = body.additionalProperties
                    .map { id, r in
                        [id, r.name, r._type, r.content, "\(r.ttl)", r.priority.map { "\($0)" } ?? ""]
                    }
                    .sorted { $0[0] < $1[0] }
                OutputFormatter.printTable(
                    headers: ["ID", "NAME", "TYPE", "CONTENT", "TTL", "PRIORITY"],
                    rows: rows
                )
            case .json:
                OutputFormatter.printJSON(body)
            }
        case .unauthorized(let err):
            throw VashError.unauthorized((try? err.body.json.message) ?? "Unauthorized. Check your API key.")
        case .undocumented(let statusCode, _):
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
