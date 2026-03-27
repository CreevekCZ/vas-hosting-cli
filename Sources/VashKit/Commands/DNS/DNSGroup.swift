import ArgumentParser

public struct DNSGroup: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "dns",
        abstract: "Manage DNS records for a domain.",
        discussion: """
            Subcommands:
              list    List all DNS records with ID, name, type, content, TTL, and priority
              create  Create a DNS record (A, AAAA, CNAME, MX, TXT, NS, SRV, etc.)
              edit    Update all fields of an existing DNS record by its ID
              delete  Delete a DNS record by its ID

            All subcommands require a domain name as the first argument.
            Record IDs from 'list' are needed for 'edit' and 'delete'.
            Example: vash dns list example.com --format json
            """,
        subcommands: [
            DNSListCommand.self,
            DNSCreateCommand.self,
            DNSEditCommand.self,
            DNSDeleteCommand.self,
        ]
    )

    public init() {}
}
