import ArgumentParser

public struct ServerGroup: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "server",
        abstract: "Manage VPS and VDS servers.",
        discussion: """
            Subcommands:
              list            List all active servers with hostname, status, tariff, and labels
              info            Show detailed info for one server (RAM, storage, OS, expiration)
              reboot          Initiate an asynchronous reboot of a server
              list-vds        List VDS hosts with VPS slot usage and storage
              install-vps     Install a new VPS on a VDS (use 'infrastructure list-os' for OS IDs)
              assign-label    Attach a label to a server for grouping
              unassign-label  Remove a label from a server

            Filter 'list' by label: vash server list --labels production --format json
            """,
        subcommands: [
            ServerListCommand.self,
            ServerInfoCommand.self,
            ServerRebootCommand.self,
            ServerListVdsCommand.self,
            ServerInstallVpsCommand.self,
            ServerAssignLabelCommand.self,
            ServerUnassignLabelCommand.self,
        ]
    )

    public init() {}
}
