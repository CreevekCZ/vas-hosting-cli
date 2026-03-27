import ArgumentParser

public struct AuthGroup: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "auth",
        abstract: "Manage vas-hosting.cz accounts and API keys.",
        discussion: """
            Subcommands:
              login    Add an account by name and API key (get your key at portal.vas-hosting.cz/api-key)
              logout   Remove a saved account
              list     List all saved accounts
              switch   Set a different account as the current default
              current  Show the currently active account name

            Multiple accounts are stored securely (Keychain on macOS, AES-256-GCM file on Linux).
            Use --account <name> on any command to override the active account without switching.
            """,
        subcommands: [
            AuthLoginCommand.self,
            AuthLogoutCommand.self,
            AuthListCommand.self,
            AuthSwitchCommand.self,
            AuthCurrentCommand.self,
        ]
    )

    public init() {}
}
