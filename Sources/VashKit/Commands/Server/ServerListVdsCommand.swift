import ArgumentParser
import Foundation
import VasHostingClient

public struct ServerListVdsCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "list-vds",
        abstract: "List all VDS (Virtual Dedicated Servers)."
    )

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.listVds()
        switch response {
        case .ok(let ok):
            let body = try ok.body.json
            switch clientOptions.format {
            case .table:
                let rows = body.additionalProperties
                    .map { hostname, vds in
                        let vpsUsed = vds.vpsCount.map { "\($0.used)/\($0.limit)" } ?? "-"
                        let storageFree = vds.storage?.primary.map { "\($0.free)/\($0.size) GB" } ?? "-"
                        return [hostname, vds.name, vpsUsed, storageFree]
                    }
                    .sorted { $0[0] < $1[0] }
                OutputFormatter.printTable(
                    headers: ["HOSTNAME", "NAME", "VPS (USED/LIMIT)", "STORAGE (FREE/TOTAL)"],
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
