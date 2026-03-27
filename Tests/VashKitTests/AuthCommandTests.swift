import XCTest
@testable import VashKit
import Foundation

final class AuthCommandTests: XCTestCase {
    private var tempDir: URL!
    private var mockStorage: MockSecureStorage!
    private var manager: AccountManager!

    override func setUp() {
        super.setUp()
        tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("VashAuthTests-\(UUID().uuidString)")
        // swiftlint:disable:next force_try
        try! FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        mockStorage = MockSecureStorage()
        manager = AccountManager(configDirectory: tempDir, storage: mockStorage)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
        super.tearDown()
    }

    // MARK: - AccountManager integration tests (via auth commands)

    func testLoginAddsAccount() throws {
        try manager.addAccount(name: "personal", apiKey: "api-key-123")
        let accounts = try manager.listAccounts()
        XCTAssertEqual(accounts.count, 1)
        XCTAssertEqual(accounts[0].name, "personal")
    }

    func testLogoutRemovesAccount() throws {
        try manager.addAccount(name: "personal", apiKey: "api-key-123")
        try manager.removeAccount(name: "personal")
        let accounts = try manager.listAccounts()
        XCTAssertTrue(accounts.isEmpty)
    }

    func testSwitchChangesCurrent() throws {
        try manager.addAccount(name: "a", apiKey: "key1")
        try manager.addAccount(name: "b", apiKey: "key2")
        try manager.switchAccount(to: "b")
        XCTAssertEqual(try manager.currentAccountName(), "b")
    }

    func testCurrentReturnsCurrentAccount() throws {
        try manager.addAccount(name: "myaccount", apiKey: "key")
        XCTAssertEqual(try manager.currentAccountName(), "myaccount")
    }

    func testCurrentReturnsNilWhenNoAccounts() throws {
        XCTAssertNil(try manager.currentAccountName())
    }

    func testMultipleAccountsWorkflow() throws {
        try manager.addAccount(name: "dev", apiKey: "dev-key")
        try manager.addAccount(name: "prod", apiKey: "prod-key")
        try manager.addAccount(name: "staging", apiKey: "staging-key")

        // Default current is first added
        XCTAssertEqual(try manager.currentAccountName(), "dev")

        // Switch to prod
        try manager.switchAccount(to: "prod")
        XCTAssertEqual(try manager.currentAccountName(), "prod")

        // API key for current (prod)
        XCTAssertEqual(try manager.apiKey(), "prod-key")

        // API key for named account
        XCTAssertEqual(try manager.apiKey(for: "staging"), "staging-key")

        // Remove prod, should fall back
        try manager.removeAccount(name: "prod")
        let current = try manager.currentAccountName()
        XCTAssertNotNil(current)
        XCTAssertNotEqual(current, "prod")
    }
}
