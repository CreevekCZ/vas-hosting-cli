import ArgumentParser
import Foundation
import VasHostingClient

public struct InfrastructureListIpsCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "list-ips",
        abstract: "List IP addresses available for server installations."
    )

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.listIpAddresses()
        switch response {
        case .ok(let ok):
            let body = try ok.body.json
            switch clientOptions.format {
            case .table:
                var rows: [[String]] = []
                if let ipv4 = body.ipv4?.additionalProperties {
                    for (ip, info) in ipv4.sorted(by: { $0.key < $1.key }) {
                        rows.append([
                            ip,
                            "IPv4",
                            info.reverse ?? "",
                            info.availableForServerInstall == true ? "Yes" : "No",
                        ])
                    }
                }
                OutputFormatter.printTable(
                    headers: ["IP ADDRESS", "VERSION", "REVERSE", "AVAILABLE"],
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
