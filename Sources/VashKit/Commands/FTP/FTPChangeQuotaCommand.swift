import ArgumentParser
import Foundation
import VasHostingClient

public struct FTPChangeQuotaCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "change-quota",
        abstract: "Change the quota of an FTP account."
    )

    @Argument(help: "Domain name.")
    var domain: String

    @Argument(help: "FTP account name.")
    var ftp: String

    @Option(name: .long, help: "New quota in MB (0 for unlimited).")
    var quota: Int

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.changeFtpQuota(
            path: .init(domain: domain, ftp: ftp),
            body: .json(.init(quota: quota))
        )
        switch response {
        case .noContent:
            let quotaStr = quota == 0 ? "unlimited" : "\(quota) MB"
            OutputFormatter.printSuccess("Quota set to \(quotaStr) for FTP account '\(ftp)'.", format: clientOptions.format)
        case .unprocessableContent(let err):
            throw VashError.apiError((try? err.body.json.message) ?? "Invalid quota")
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
