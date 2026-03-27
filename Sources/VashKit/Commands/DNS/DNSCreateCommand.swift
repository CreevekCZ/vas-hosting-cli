import ArgumentParser
import Foundation
import VasHostingClient

public struct DNSCreateCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a DNS record."
    )

    @Argument(help: "Domain name.")
    var domain: String

    @Option(name: .long, help: "Record name.")
    var name: String

    @Option(name: .long, help: "Record content/value.")
    var content: String

    @Option(name: .long, help: "Record type (A, CNAME, MX, TXT, etc.).",
            completion: .list(["A", "AAAA", "CNAME", "MX", "TXT", "NS", "SRV", "CAA", "PTR", "SOA"]))
    var type: String

    @Option(name: .long, help: "TTL in seconds (60-86400).")
    var ttl: Int

    @Option(name: .long, help: "Priority (0-65535, for MX records).")
    var priority: Int?

    @Option(name: .long, help: "Internal note.")
    var note: String?

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.createDnsRecord(
            path: .init(domain: domain),
            body: .json(.init(name: name, content: content, _type: type, ttl: ttl, priority: priority, note: note))
        )
        switch response {
        case .noContent:
            OutputFormatter.printSuccess("DNS record created.", format: clientOptions.format)
        case .conflict(let err):
            throw VashError.apiError((try? err.body.json.message) ?? "Record already exists")
        case .unprocessableContent(let err):
            throw VashError.apiError((try? err.body.json.message) ?? "Invalid parameters")
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
