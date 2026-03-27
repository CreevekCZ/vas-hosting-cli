import ArgumentParser

public struct EmailGroup: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "email",
        abstract: "Manage email accounts, aliases, forwarding, and auto-reply.",
        discussion: """
            Subcommands:
              list             List email accounts with quota, status, and auto-reply state
              create           Create a new email account (name@domain)
              change-password  Change an email account password
              change-quota     Set the mailbox quota in MB (0 for unlimited)
              create-alias     Add an alias address pointing to an account
              delete-alias     Remove an alias from an account
              auto-reply       Enable or disable auto-reply with custom subject and body
              forwarding       Configure forwarding to one or more external addresses
              delete           Delete an email account permanently

            All subcommands require a domain name and email name (the part before @domain).
            Example: vash email list example.com --format json
            """,
        subcommands: [
            EmailListCommand.self,
            EmailCreateCommand.self,
            EmailChangePasswordCommand.self,
            EmailChangeQuotaCommand.self,
            EmailCreateAliasCommand.self,
            EmailDeleteAliasCommand.self,
            EmailAutoReplyCommand.self,
            EmailForwardingCommand.self,
            EmailDeleteCommand.self,
        ]
    )

    public init() {}
}
