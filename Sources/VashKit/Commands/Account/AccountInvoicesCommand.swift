import ArgumentParser
import Foundation
import VasHostingClient

public struct AccountInvoicesCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "invoices",
        abstract: "List unpaid invoices."
    )

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.listUnpaidInvoices()
        switch response {
        case .ok(let ok):
            let body = try ok.body.json
            switch clientOptions.format {
            case .table:
                let rows = body.additionalProperties.map { key, invoice in
                    [key, invoice.totalPrice, invoice.createdAt, invoice.expiresAt]
                }.sorted { $0[0] < $1[0] }
                OutputFormatter.printTable(
                    headers: ["VARIABLE SYMBOL", "TOTAL PRICE", "CREATED AT", "EXPIRES AT"],
                    rows: rows
                )
            case .json:
                OutputFormatter.printJSON(body)
            }
        case .unauthorized(let err):
            let msg = (try? err.body.json.message) ?? "Unauthorized. Check your API key."
            throw VashError.unauthorized(msg)
        case .undocumented(let statusCode, _):
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
