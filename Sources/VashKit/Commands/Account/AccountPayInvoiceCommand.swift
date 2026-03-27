import ArgumentParser
import Foundation
import VasHostingClient

public struct AccountPayInvoiceCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "pay-invoice",
        abstract: "Pay an unpaid invoice using account credit."
    )

    @Argument(help: "Variable symbol of the invoice.")
    var variableSymbol: String

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.payInvoiceWithCredit(
            path: .init(variableSymbol: variableSymbol)
        )
        switch response {
        case .noContent:
            OutputFormatter.printSuccess("Invoice \(variableSymbol) paid successfully.", format: clientOptions.format)
        case .unauthorized(let err):
            let msg = (try? err.body.json.message) ?? "Unauthorized. Check your API key."
            throw VashError.unauthorized(msg)
        case .notFound(let err):
            let msg = (try? err.body.json.message) ?? "Invoice not found"
            throw VashError.notFound(msg)
        case .undocumented(let statusCode, _):
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
