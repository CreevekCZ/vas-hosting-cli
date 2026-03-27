import ArgumentParser

public struct ServerLabelGroup: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "server-label",
        abstract: "Manage server labels for grouping and filtering servers.",
        discussion: """
            Subcommands:
              list    List all labels with their display color
              create  Create a new label (optionally with a hex color like #ff0000)
              edit    Rename a label or change its color
              delete  Delete a label (automatically unassigned from all servers)

            Labels can be used to filter 'vash server list --labels <name>'.
            """,
        subcommands: [
            ServerLabelListCommand.self,
            ServerLabelCreateCommand.self,
            ServerLabelDeleteCommand.self,
            ServerLabelEditCommand.self,
        ]
    )

    public init() {}
}
