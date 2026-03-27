import ArgumentParser
import Foundation
import VasHostingClient

public struct DNSDeleteCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a DNS record."
    )

    @Argument(help: "Domain name.")
    var domain: String

    @Argument(help: "DNS record ID.")
    var recordId: String

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.deleteDnsRecord(
            path: .init(domain: domain, dnsRecordId: recordId)
        )
        switch response {
        case .noContent:
            OutputFormatter.printSuccess("DNS record \(recordId) deleted.", format: clientOptions.format)
        case .notFound(let err):
            throw VashError.notFound((try? err.body.json.message) ?? "Record not found")
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
