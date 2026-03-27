import ArgumentParser

public struct AccountGroup: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "account",
        abstract: "Manage your hosting account.",
        discussion: """
            Subcommands:
              invoices     List all unpaid invoices with amounts and due dates
              pay-invoice  Pay an invoice using your account credit balance

            Use 'vash account invoices --format json' to get machine-readable invoice data.
            """,
        subcommands: [
            AccountInvoicesCommand.self,
            AccountPayInvoiceCommand.self,
        ]
    )

    public init() {}
}
