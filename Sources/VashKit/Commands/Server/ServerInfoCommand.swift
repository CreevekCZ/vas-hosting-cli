import ArgumentParser
import Foundation
import VasHostingClient

public struct ServerInfoCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "info",
        abstract: "Get detailed server information."
    )

    @Argument(help: "Server hostname.")
    var hostname: String

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.getServerInfo(path: .init(serverHostname: hostname))
        switch response {
        case .ok(let ok):
            let server = try ok.body.json
            switch clientOptions.format {
            case .table:
                OutputFormatter.printTable(headers: ["FIELD", "VALUE"], rows: tableRows(for: server))
            case .json:
                OutputFormatter.printJSON(server)
            }
        case .notFound(let err):
            throw VashError.notFound((try? err.body.json.message) ?? "Server not found")
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }

    private func tableRows(for server: Components.Schemas.ServerDetail) -> [[String]] {
        var rows: [[String]] = [
            ["ID", "\(server.id)"],
            ["Status", server.status],
        ]
        if let exp = server.expiration { rows.append(["Expiration", exp]) }
        if let tariff = server.tariff { rows.append(["Tariff", tariff]) }
        if let os = server.operatingSystem { rows.append(["OS", os]) }
        if let ram = server.ram {
            rows.append(["RAM", String(format: "%.1f GiB", Double(ram) / 1_073_741_824)])
        }
        if let storage = server.storage?.primary {
            rows.append(["Storage", String(format: "%.1f GB", Double(storage) / 1_000_000_000)])
        }
        return rows
    }
}
