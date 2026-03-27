import ArgumentParser

public struct FTPGroup: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "ftp",
        abstract: "Manage FTP accounts for a domain.",
        discussion: """
            Subcommands:
              list             List FTP accounts with name, quota, and lock status
              create           Create an FTP account with a directory path and password
              change-password  Change the FTP account password (8-64 characters)
              change-quota     Set the FTP quota in MB (0 for unlimited)
              lock             Disable FTP access for an account without deleting it
              unlock           Re-enable a previously locked FTP account
              delete           Delete an FTP account permanently

            All subcommands require a domain name as the first argument.
            Example: vash ftp list example.com --format json
            """,
        subcommands: [
            FTPListCommand.self,
            FTPCreateCommand.self,
            FTPChangePasswordCommand.self,
            FTPChangeQuotaCommand.self,
            FTPLockCommand.self,
            FTPUnlockCommand.self,
            FTPDeleteCommand.self,
        ]
    )

    public init() {}
}
