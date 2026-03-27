import ArgumentParser
import Foundation

@available(macOS 10.15, macCatalyst 13, iOS 13, tvOS 13, watchOS 6, *)
public struct VashCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "vash",
        abstract: "CLI for managing vas-hosting.cz hosting accounts.",
        discussion: """
            QUICK START:
              1. Authenticate:   vash auth login --name personal --api-key <key>
              2. List servers:   vash server list --format json
              3. List domains:   vash domain info example.com --format json

            OUTPUT FORMATS:
              All API commands support --format json (machine-readable) or --format table (human-readable).
              Use --format json for scripting and AI agent integration.
              Errors in JSON mode are returned as: {"error":"<message>","code":"<code>"}
              Error codes: unauthorized, not_found, api_error, unexpected_status

            MULTI-ACCOUNT:
              Store multiple accounts with 'vash auth login'.
              Switch globally with 'vash auth switch <name>'.
              Override per-command with --account <name>.

            WORKFLOW EXAMPLE:
              vash auth login --name prod --api-key sk-xxx
              vash server list --format json
              vash database create example.com --name mydb --type mysql --password s3cr3t
              vash dns create example.com --name @ --type A --content 1.2.3.4 --ttl 3600
            """,
        subcommands: [
            AuthGroup.self,
            AccountGroup.self,
            DomainGroup.self,
            DatabaseGroup.self,
            DNSGroup.self,
            EmailGroup.self,
            FTPGroup.self,
            ServerGroup.self,
            ServerLabelGroup.self,
            InfrastructureGroup.self,
        ]
    )

    public init() {}
}
