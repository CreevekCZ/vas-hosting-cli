import ArgumentParser

public struct InfrastructureGroup: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "infrastructure",
        abstract: "List available operating systems and IP addresses for server provisioning.",
        discussion: """
            Subcommands:
              list-os   List available OS images with ID, name, and distribution.
                        Use the OS ID when running 'vash server install-vps --os <id>'.
              list-ips  List available IP addresses with version, reverse DNS, and availability.
                        Use the IP when running 'vash server install-vps --ip-address <ip>'.
            """,
        subcommands: [
            InfrastructureListOsCommand.self,
            InfrastructureListIpsCommand.self,
        ]
    )

    public init() {}
}
