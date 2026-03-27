import ArgumentParser
import Foundation
import VasHostingClient

public struct FTPChangePasswordCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "change-password",
        abstract: "Change the password of an FTP account."
    )

    @Argument(help: "Domain name.")
    var domain: String

    @Argument(help: "FTP account name.")
    var ftp: String

    @Option(name: .long, help: "New password (8-64 characters).")
    var password: String

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.changeFtpPassword(
            path: .init(domain: domain, ftp: ftp),
            body: .json(.init(password: password))
        )
        switch response {
        case .noContent:
            OutputFormatter.printSuccess("Password changed for FTP account '\(ftp)'.", format: clientOptions.format)
        case .unprocessableContent(let err):
            throw VashError.apiError((try? err.body.json.message) ?? "Invalid password")
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
