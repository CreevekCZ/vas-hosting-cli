import ArgumentParser

public struct DomainGroup: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "domain",
        abstract: "Manage hosting domains.",
        discussion: """
            Subcommands:
              info        Show domain details: ID, name, expiration, tariff
              change-php  Switch the PHP version for a domain (e.g., --version 8.3)

            Domain names are used as identifiers in database, dns, email, and ftp commands.
            """,
        subcommands: [
            DomainInfoCommand.self,
            DomainChangePhpCommand.self,
        ]
    )

    public init() {}
}
