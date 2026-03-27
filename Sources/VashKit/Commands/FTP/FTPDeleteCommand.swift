import ArgumentParser
import Foundation
import VasHostingClient

public struct FTPDeleteCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete an FTP account."
    )

    @Argument(help: "Domain name.")
    var domain: String

    @Argument(help: "FTP account name.")
    var ftp: String

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.deleteFtpAccount(path: .init(domain: domain, ftp: ftp))
        switch response {
        case .noContent:
            OutputFormatter.printSuccess("FTP account '\(ftp)' deleted.", format: clientOptions.format)
        case .notFound(let err):
            throw VashError.notFound((try? err.body.json.message) ?? "Account not found")
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
