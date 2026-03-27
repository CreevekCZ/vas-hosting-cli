import ArgumentParser
import Foundation
import VasHostingClient
import OpenAPIURLSession

/// Shared options available on every command that calls the API.
public struct ClientOptions: ParsableArguments {
    @Option(name: .long, help: "Account name to use (overrides current account).")
    public var account: String?

    @Option(name: .long, help: "Output format: table or json.")
    public var format: OutputFormat = .table

    public init() {}

    public func makeClient(accountManager: AccountManager = AccountManager()) throws -> Client {
        let apiKey = try accountManager.apiKey(for: account)
        return Client(
            serverURL: try Servers.Server1.url(),
            transport: URLSessionTransport(),
            middlewares: [AuthMiddleware(apiKey: apiKey)]
        )
    }
}
