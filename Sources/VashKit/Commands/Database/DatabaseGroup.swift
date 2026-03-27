import ArgumentParser

public struct DatabaseGroup: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "database",
        abstract: "Manage MySQL and PostgreSQL databases for a domain.",
        discussion: """
            Subcommands:
              list             List all databases with name, user, type (mysql/postgresql), and size in MB
              create           Create a new database with a name, type, and password
              change-password  Change the database user password (8-64 characters)
              backup           Trigger an immediate backup of a database
              delete           Delete a database permanently

            All subcommands require a domain name as the first argument.
            Example: vash database list example.com --format json
            """,
        subcommands: [
            DatabaseListCommand.self,
            DatabaseCreateCommand.self,
            DatabaseChangePasswordCommand.self,
            DatabaseBackupCommand.self,
            DatabaseDeleteCommand.self,
        ]
    )

    public init() {}
}
