import ArgumentParser
import Foundation
import VasHostingClient

public struct DomainInfoCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "info",
        abstract: "Get domain information."
    )

    @Argument(help: "Domain name (e.g., example.com).")
    var domain: String

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.getDomainInfo(path: .init(domain: domain))
        switch response {
        case .ok(let ok):
            let info = try ok.body.json
            switch clientOptions.format {
            case .table:
                var rows: [[String]] = [
                    ["ID", "\(info.id)"],
                    ["Name", info.name],
                ]
                if let exp = info.expiration { rows.append(["Expiration", exp]) }
                if let tariff = info.tariff { rows.append(["Tariff", tariff]) }
                OutputFormatter.printTable(headers: ["FIELD", "VALUE"], rows: rows)
            case .json:
                OutputFormatter.printJSON(info)
            }
        case .unauthorized(let err):
            throw VashError.unauthorized((try? err.body.json.message) ?? "Unauthorized. Check your API key.")
        case .notFound(let err):
            throw VashError.notFound((try? err.body.json.message) ?? "Domain not found")
        case .undocumented(let statusCode, _):
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
