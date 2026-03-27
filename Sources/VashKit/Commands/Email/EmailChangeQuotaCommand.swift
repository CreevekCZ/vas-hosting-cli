import ArgumentParser
import Foundation
import VasHostingClient

public struct EmailChangeQuotaCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "change-quota",
        abstract: "Change the quota of an email account."
    )

    @Argument(help: "Domain name.")
    var domain: String

    @Argument(help: "Email account name (before @domain).")
    var email: String

    @Option(name: .long, help: "New quota in MB (0 for unlimited).")
    var quota: Int

    @OptionGroup var clientOptions: ClientOptions

    public init() {}

    public func run() async throws {
        let client = try clientOptions.makeClient()
        let response = try await client.changeEmailQuota(
            path: .init(domain: domain, email: email),
            body: .json(.init(quota: quota))
        )
        switch response {
        case .noContent:
            let quotaStr = quota == 0 ? "unlimited" : "\(quota) MB"
            OutputFormatter.printSuccess("Quota set to \(quotaStr) for '\(email)@\(domain)'.", format: clientOptions.format)
        case .unprocessableContent(let err):
            throw VashError.apiError((try? err.body.json.message) ?? "Invalid quota")
        case .undocumented(let statusCode, _):
            if statusCode == 401 { throw VashError.unauthorized("Unauthorized. Check your API key.") }
            throw VashError.unexpectedStatus(statusCode)
        }
    }
}
