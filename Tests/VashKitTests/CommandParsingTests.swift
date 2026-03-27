import XCTest
import ArgumentParser
@testable import VashKit
import VasHostingClient

final class CommandParsingTests: XCTestCase {

    // MARK: - Auth

    func testAuthLoginParsesNameAndApiKey() throws {
        let cmd = try AuthLoginCommand.parse(["--name", "personal", "--api-key", "key123"])
        XCTAssertEqual(cmd.name, "personal")
        XCTAssertEqual(cmd.apiKey, "key123")
    }

    func testAuthLoginRequiresName() {
        XCTAssertThrowsError(try AuthLoginCommand.parse(["--api-key", "key123"]))
    }

    func testAuthLoginRequiresApiKey() {
        XCTAssertThrowsError(try AuthLoginCommand.parse(["--name", "personal"]))
    }

    func testAuthLogoutParsesName() throws {
        let cmd = try AuthLogoutCommand.parse(["myaccount"])
        XCTAssertEqual(cmd.name, "myaccount")
    }

    func testAuthSwitchParsesName() throws {
        let cmd = try AuthSwitchCommand.parse(["work"])
        XCTAssertEqual(cmd.name, "work")
    }

    // MARK: - ClientOptions

    func testClientOptionsDefaultFormat() throws {
        let opts = try ClientOptions.parse([])
        XCTAssertEqual(opts.format, .table)
    }

    func testClientOptionsJsonFormat() throws {
        let opts = try ClientOptions.parse(["--format", "json"])
        XCTAssertEqual(opts.format, .json)
    }

    func testClientOptionsAccountOverride() throws {
        let opts = try ClientOptions.parse(["--account", "work"])
        XCTAssertEqual(opts.account, "work")
    }

    func testClientOptionsAccountDefaultsToNil() throws {
        let opts = try ClientOptions.parse([])
        XCTAssertNil(opts.account)
    }

    // MARK: - Account

    func testAccountInvoicesParsesNoArgs() throws {
        _ = try AccountInvoicesCommand.parse([])
    }

    func testAccountPayInvoiceParsesVariableSymbol() throws {
        let cmd = try AccountPayInvoiceCommand.parse(["3023000368"])
        XCTAssertEqual(cmd.variableSymbol, "3023000368")
    }

    // MARK: - Domain

    func testDomainInfoParsesDomain() throws {
        let cmd = try DomainInfoCommand.parse(["example.com"])
        XCTAssertEqual(cmd.domain, "example.com")
    }

    func testDomainChangePhpParsesArgs() throws {
        let cmd = try DomainChangePhpCommand.parse(["example.com", "--version", "8.2"])
        XCTAssertEqual(cmd.domain, "example.com")
        XCTAssertEqual(cmd.version, "8.2")
    }

    func testDomainChangePhpRequiresVersion() {
        XCTAssertThrowsError(try DomainChangePhpCommand.parse(["example.com"]))
    }

    // MARK: - Database

    func testDatabaseListParsesDomain() throws {
        let cmd = try DatabaseListCommand.parse(["example.com"])
        XCTAssertEqual(cmd.domain, "example.com")
    }

    func testDatabaseCreateParsesArgs() throws {
        let cmd = try DatabaseCreateCommand.parse([
            "example.com",
            "--name", "mydb",
            "--type", "mysql",
            "--password", "secret123",
        ])
        XCTAssertEqual(cmd.domain, "example.com")
        XCTAssertEqual(cmd.name, "mydb")
        XCTAssertEqual(cmd.type, "mysql")
        XCTAssertEqual(cmd.password, "secret123")
        XCTAssertNil(cmd.encoding)
        XCTAssertNil(cmd.note)
    }

    func testDatabaseCreateWithOptionalEncoding() throws {
        let cmd = try DatabaseCreateCommand.parse([
            "example.com",
            "--name", "mydb",
            "--type", "mysql",
            "--password", "secret123",
            "--encoding", "utf8mb4",
        ])
        XCTAssertEqual(cmd.encoding, "utf8mb4")
    }

    func testDatabaseChangePasswordParsesArgs() throws {
        let cmd = try DatabaseChangePasswordCommand.parse(["example.com", "mydb", "--password", "newpass"])
        XCTAssertEqual(cmd.domain, "example.com")
        XCTAssertEqual(cmd.database, "mydb")
        XCTAssertEqual(cmd.password, "newpass")
    }

    func testDatabaseBackupParsesArgs() throws {
        let cmd = try DatabaseBackupCommand.parse(["example.com", "mydb"])
        XCTAssertEqual(cmd.domain, "example.com")
        XCTAssertEqual(cmd.database, "mydb")
    }

    func testDatabaseDeleteParsesArgs() throws {
        let cmd = try DatabaseDeleteCommand.parse(["example.com", "mydb"])
        XCTAssertEqual(cmd.domain, "example.com")
        XCTAssertEqual(cmd.database, "mydb")
    }

    // MARK: - DNS

    func testDNSListParsesDomain() throws {
        let cmd = try DNSListCommand.parse(["example.com"])
        XCTAssertEqual(cmd.domain, "example.com")
    }

    func testDNSCreateParsesRequiredArgs() throws {
        let cmd = try DNSCreateCommand.parse([
            "example.com",
            "--name", "www",
            "--content", "1.2.3.4",
            "--type", "A",
            "--ttl", "3600",
        ])
        XCTAssertEqual(cmd.domain, "example.com")
        XCTAssertEqual(cmd.name, "www")
        XCTAssertEqual(cmd.content, "1.2.3.4")
        XCTAssertEqual(cmd.type, "A")
        XCTAssertEqual(cmd.ttl, 3600)
        XCTAssertNil(cmd.priority)
        XCTAssertNil(cmd.note)
    }

    func testDNSCreateWithOptionalPriority() throws {
        let cmd = try DNSCreateCommand.parse([
            "example.com",
            "--name", "mail",
            "--content", "mail.example.com",
            "--type", "MX",
            "--ttl", "3600",
            "--priority", "10",
        ])
        XCTAssertEqual(cmd.priority, 10)
    }

    func testDNSEditParsesArgs() throws {
        let cmd = try DNSEditCommand.parse([
            "example.com", "139816",
            "--name", "www",
            "--content", "5.6.7.8",
            "--type", "A",
            "--ttl", "7200",
        ])
        XCTAssertEqual(cmd.domain, "example.com")
        XCTAssertEqual(cmd.recordId, "139816")
        XCTAssertEqual(cmd.content, "5.6.7.8")
        XCTAssertEqual(cmd.ttl, 7200)
        XCTAssertNil(cmd.priority)
    }

    func testDNSDeleteParsesArgs() throws {
        let cmd = try DNSDeleteCommand.parse(["example.com", "139816"])
        XCTAssertEqual(cmd.domain, "example.com")
        XCTAssertEqual(cmd.recordId, "139816")
    }

    // MARK: - Email

    func testEmailListParsesDomain() throws {
        let cmd = try EmailListCommand.parse(["example.com"])
        XCTAssertEqual(cmd.domain, "example.com")
    }

    func testEmailCreateParsesArgs() throws {
        let cmd = try EmailCreateCommand.parse([
            "example.com",
            "--name", "john",
            "--display-name", "John Doe",
            "--password", "pass123",
            "--quota", "500",
        ])
        XCTAssertEqual(cmd.domain, "example.com")
        XCTAssertEqual(cmd.name, "john")
        XCTAssertEqual(cmd.displayName, "John Doe")
        XCTAssertEqual(cmd.password, "pass123")
        XCTAssertEqual(cmd.quota, 500)
    }

    func testEmailChangePasswordParsesArgs() throws {
        let cmd = try EmailChangePasswordCommand.parse(["example.com", "john", "--password", "newpass"])
        XCTAssertEqual(cmd.domain, "example.com")
        XCTAssertEqual(cmd.email, "john")
        XCTAssertEqual(cmd.password, "newpass")
    }

    func testEmailChangeQuotaParsesArgs() throws {
        let cmd = try EmailChangeQuotaCommand.parse(["example.com", "john", "--quota", "1000"])
        XCTAssertEqual(cmd.domain, "example.com")
        XCTAssertEqual(cmd.email, "john")
        XCTAssertEqual(cmd.quota, 1000)
    }

    func testEmailCreateAliasParsesArgs() throws {
        let cmd = try EmailCreateAliasCommand.parse(["example.com", "john", "--name", "j.doe"])
        XCTAssertEqual(cmd.domain, "example.com")
        XCTAssertEqual(cmd.email, "john")
        XCTAssertEqual(cmd.name, "j.doe")
    }

    func testEmailDeleteAliasParsesArgs() throws {
        let cmd = try EmailDeleteAliasCommand.parse(["example.com", "john", "j.doe"])
        XCTAssertEqual(cmd.domain, "example.com")
        XCTAssertEqual(cmd.email, "john")
        XCTAssertEqual(cmd.alias, "j.doe")
    }

    func testEmailAutoReplyParsesEnable() throws {
        let cmd = try EmailAutoReplyCommand.parse([
            "example.com", "john", "--enable",
        ])
        XCTAssertEqual(cmd.domain, "example.com")
        XCTAssertEqual(cmd.email, "john")
        XCTAssertTrue(cmd.enable)
        XCTAssertFalse(cmd.disable)
        XCTAssertNil(cmd.subject)
        XCTAssertNil(cmd.content)
    }

    func testEmailAutoReplyParsesDisable() throws {
        let cmd = try EmailAutoReplyCommand.parse(["example.com", "john", "--disable"])
        XCTAssertTrue(cmd.disable)
    }

    func testEmailForwardingParsesArgs() throws {
        let cmd = try EmailForwardingCommand.parse([
            "example.com", "john",
            "--emails", "forward@other.com",
        ])
        XCTAssertEqual(cmd.domain, "example.com")
        XCTAssertEqual(cmd.email, "john")
        XCTAssertEqual(cmd.emails, "forward@other.com")
    }

    func testEmailDeleteParsesArgs() throws {
        let cmd = try EmailDeleteCommand.parse(["example.com", "john"])
        XCTAssertEqual(cmd.domain, "example.com")
        XCTAssertEqual(cmd.email, "john")
    }

    // MARK: - FTP

    func testFTPListParsesDomain() throws {
        let cmd = try FTPListCommand.parse(["example.com"])
        XCTAssertEqual(cmd.domain, "example.com")
    }

    func testFTPCreateParsesArgs() throws {
        let cmd = try FTPCreateCommand.parse([
            "example.com",
            "--name", "ftpuser",
            "--directory", "/www",
            "--password", "ftppass",
            "--quota", "1000",
        ])
        XCTAssertEqual(cmd.domain, "example.com")
        XCTAssertEqual(cmd.name, "ftpuser")
        XCTAssertEqual(cmd.directory, "/www")
        XCTAssertEqual(cmd.password, "ftppass")
        XCTAssertEqual(cmd.quota, 1000)
    }

    func testFTPChangePasswordParsesArgs() throws {
        let cmd = try FTPChangePasswordCommand.parse(["example.com", "ftpuser", "--password", "newpass"])
        XCTAssertEqual(cmd.domain, "example.com")
        XCTAssertEqual(cmd.ftp, "ftpuser")
        XCTAssertEqual(cmd.password, "newpass")
    }

    func testFTPChangeQuotaParsesArgs() throws {
        let cmd = try FTPChangeQuotaCommand.parse(["example.com", "ftpuser", "--quota", "2000"])
        XCTAssertEqual(cmd.domain, "example.com")
        XCTAssertEqual(cmd.ftp, "ftpuser")
        XCTAssertEqual(cmd.quota, 2000)
    }

    func testFTPLockParsesArgs() throws {
        let cmd = try FTPLockCommand.parse(["example.com", "ftpuser"])
        XCTAssertEqual(cmd.domain, "example.com")
        XCTAssertEqual(cmd.ftp, "ftpuser")
    }

    func testFTPUnlockParsesArgs() throws {
        let cmd = try FTPUnlockCommand.parse(["example.com", "ftpuser"])
        XCTAssertEqual(cmd.domain, "example.com")
        XCTAssertEqual(cmd.ftp, "ftpuser")
    }

    func testFTPDeleteParsesArgs() throws {
        let cmd = try FTPDeleteCommand.parse(["example.com", "ftpuser"])
        XCTAssertEqual(cmd.domain, "example.com")
        XCTAssertEqual(cmd.ftp, "ftpuser")
    }

    // MARK: - Server

    func testServerListParsesNoArgs() throws {
        _ = try ServerListCommand.parse([])
    }

    func testServerInfoParsesHostname() throws {
        let cmd = try ServerInfoCommand.parse(["srv01.example.com"])
        XCTAssertEqual(cmd.hostname, "srv01.example.com")
    }

    func testServerRebootParsesHostname() throws {
        let cmd = try ServerRebootCommand.parse(["srv01.example.com"])
        XCTAssertEqual(cmd.hostname, "srv01.example.com")
    }

    func testServerListVdsParsesNoArgs() throws {
        _ = try ServerListVdsCommand.parse([])
    }

    func testServerInstallVpsParsesArgs() throws {
        let cmd = try ServerInstallVpsCommand.parse([
            "vds01.example.com",
            "--cpu", "2",
            "--ram", "2048",
            "--storage-size", "20",
            "--storage-location", "1",
            "--os", "ubuntu",
        ])
        XCTAssertEqual(cmd.hostname, "vds01.example.com")
        XCTAssertEqual(cmd.cpu, 2)
        XCTAssertEqual(cmd.ram, 2048)
        XCTAssertEqual(cmd.storageSize, 20)
        XCTAssertEqual(cmd.storageLocation, 1)
        XCTAssertEqual(cmd.os, "ubuntu")
        XCTAssertNil(cmd.serverName)
        XCTAssertNil(cmd.ipAddress)
    }

    func testServerAssignLabelParsesArgs() throws {
        let cmd = try ServerAssignLabelCommand.parse(["srv01.example.com", "--label", "production"])
        XCTAssertEqual(cmd.hostname, "srv01.example.com")
        XCTAssertEqual(cmd.label, "production")
    }

    func testServerUnassignLabelParsesArgs() throws {
        let cmd = try ServerUnassignLabelCommand.parse(["srv01.example.com", "--label", "production"])
        XCTAssertEqual(cmd.hostname, "srv01.example.com")
        XCTAssertEqual(cmd.label, "production")
    }

    // MARK: - Server Label

    func testServerLabelListParsesNoArgs() throws {
        _ = try ServerLabelListCommand.parse([])
    }

    func testServerLabelCreateParsesArgs() throws {
        let cmd = try ServerLabelCreateCommand.parse(["--name", "production", "--color", "#ff0000"])
        XCTAssertEqual(cmd.name, "production")
        XCTAssertEqual(cmd.color, "#ff0000")
    }

    func testServerLabelCreateColorIsOptional() throws {
        let cmd = try ServerLabelCreateCommand.parse(["--name", "production"])
        XCTAssertEqual(cmd.name, "production")
        XCTAssertNil(cmd.color)
    }

    func testServerLabelEditParsesArgs() throws {
        let cmd = try ServerLabelEditCommand.parse(["production", "--color", "#00ff00"])
        XCTAssertEqual(cmd.name, "production")
        XCTAssertEqual(cmd.color, "#00ff00")
    }

    func testServerLabelEditNewName() throws {
        let cmd = try ServerLabelEditCommand.parse(["production", "--new-name", "prod"])
        XCTAssertEqual(cmd.name, "production")
        XCTAssertEqual(cmd.newName, "prod")
    }

    func testServerLabelDeleteParsesArgs() throws {
        let cmd = try ServerLabelDeleteCommand.parse(["production"])
        XCTAssertEqual(cmd.name, "production")
    }

    // MARK: - Infrastructure

    func testInfrastructureListOsParsesNoArgs() throws {
        _ = try InfrastructureListOsCommand.parse([])
    }

    func testInfrastructureListIpsParsesNoArgs() throws {
        _ = try InfrastructureListIpsCommand.parse([])
    }
}
