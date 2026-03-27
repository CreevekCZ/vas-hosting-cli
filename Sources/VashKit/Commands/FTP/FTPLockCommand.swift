import ArgumentParser
import Foundation
import VasHostingClient

public struct FTPLockCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "lock",
        abstract: "Lock (disable) an FTP account."
    )

    @Argument(help: "Domain name.")
    var domain: String

    @Argument(help: "FTP account name.")
    var ftp: String

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.lockFtpAccount(path: .init(domain: domain, ftp: ftp))
        switch response {
        case .noContent:
            OutputFormatter.printSuccess("FTP account '\(ftp)' locked.", format: clientOptions.format)
        case .notFound(let err):
            throw VashError.notFound((try? err.body.json.message) ?? "Account not found")
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
