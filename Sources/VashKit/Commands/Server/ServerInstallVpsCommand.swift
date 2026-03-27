import ArgumentParser
import Foundation
import VasHostingClient

public struct ServerInstallVpsCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "install-vps",
        abstract: "Install a VPS on a VDS."
    )

    @Argument(help: "VDS hostname.")
    var hostname: String

    @Option(name: .long, help: "CPU frequency in MHz (greater than 3).")
    var cpu: Int

    @Option(name: .long, help: "RAM in GiB (minimum 2).")
    var ram: Int

    @Option(name: .long, help: "Primary storage size in GB.")
    var storageSize: Int

    @Option(name: .long, help: "Disk slot number on VDS.")
    var storageLocation: Int

    @Option(name: .long, help: "OS identifier (use 'vash infrastructure list-os' to see options).")
    var os: String

    @Option(name: .long, help: "Server name (optional).")
    var serverName: String?

    @Option(name: .long, help: "IP address (optional, use 'vash infrastructure list-ips').")
    var ipAddress: String?

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.installVpsOnVds(
            path: .init(serverHostname: hostname),
            body: .json(.init(
                cpu: cpu, ram: ram,
                primaryStorageSize: storageSize,
                primaryStorageLocation: storageLocation,
                operatingSystem: os,
                serverName: serverName,
                ipAddress: ipAddress
            ))
        )
        switch response {
        case .noContent:
            OutputFormatter.printSuccess("VPS installation started on '\(hostname)'.", format: clientOptions.format)
        case .badRequest(let err):
            throw VashError.apiError((try? err.body.json.message) ?? "Bad request")
        case .unauthorized(let err):
            throw VashError.unauthorized((try? err.body.json.message) ?? "Insufficient permissions.")
        case .notFound(let err):
            throw VashError.notFound((try? err.body.json.message) ?? "VDS not found")
        case .unprocessableContent(let err):
            throw VashError.apiError((try? err.body.json.message) ?? "Invalid parameters")
        case .undocumented(let statusCode, _):
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
