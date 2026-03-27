import ArgumentParser
import Foundation
import VasHostingClient

public struct FTPCreateCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create an FTP account."
    )

    @Argument(help: "Domain name.")
    var domain: String

    @Option(name: .long, help: "FTP account name.")
    var name: String

    @Option(name: .long, help: "Directory path.")
    var directory: String

    @Option(name: .long, help: "Password (8-64 characters).")
    var password: String

    @Option(name: .long, help: "Quota in MB (0 for unlimited).")
    var quota: Int = 0

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.createFtpAccount(
            path: .init(domain: domain),
            body: .json(.init(name: name, directory: directory, password: password, quota: quota))
        )
        switch response {
        case .noContent:
            OutputFormatter.printSuccess("FTP account '\(name)' created.", format: clientOptions.format)
        case .conflict(let err):
            throw VashError.apiError((try? err.body.json.message) ?? "Account already exists")
        case .unprocessableContent(let err):
            throw VashError.apiError((try? err.body.json.message) ?? "Invalid parameters")
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
