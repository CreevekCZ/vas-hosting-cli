import XCTest
@testable import VashKit
import Foundation

final class AccountManagerTests: XCTestCase {
    private var tempDir: URL!
    private var mockStorage: MockSecureStorage!
    private var manager: AccountManager!

    override func setUp() {
        super.setUp()
        tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("VashKitTests-\(UUID().uuidString)")
        // swiftlint:disable:next force_try
        try! FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        mockStorage = MockSecureStorage()
        manager = AccountManager(configDirectory: tempDir, storage: mockStorage)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
        super.tearDown()
    }

    func testAddFirstAccountSetsAsCurrent() throws {
        try manager.addAccount(name: "personal", apiKey: "key123")
        let current = try manager.currentAccountName()
        XCTAssertEqual(current, "personal")
        XCTAssertEqual(mockStorage.stored["vash.account.personal"], "key123")
    }

    func testAddSecondAccountDoesNotChangeCurrent() throws {
        try manager.addAccount(name: "personal", apiKey: "key1")
        try manager.addAccount(name: "work", apiKey: "key2")
        let current = try manager.currentAccountName()
        XCTAssertEqual(current, "personal")
    }

    func testAddDuplicateAccountThrows() throws {
        try manager.addAccount(name: "personal", apiKey: "key1")
        XCTAssertThrowsError(try manager.addAccount(name: "personal", apiKey: "key2")) { error in
            XCTAssertEqual(error as? AccountError, .accountAlreadyExists("personal"))
        }
    }

    func testListAccounts() throws {
        try manager.addAccount(name: "a", apiKey: "k1")
        try manager.addAccount(name: "b", apiKey: "k2")
        let accounts = try manager.listAccounts()
        XCTAssertEqual(accounts.map(\.name), ["a", "b"])
    }

    func testSwitchAccount() throws {
        try manager.addAccount(name: "personal", apiKey: "key1")
        try manager.addAccount(name: "work", apiKey: "key2")
        try manager.switchAccount(to: "work")
        XCTAssertEqual(try manager.currentAccountName(), "work")
    }

    func testSwitchToNonexistentAccountThrows() throws {
        try manager.addAccount(name: "personal", apiKey: "key1")
        XCTAssertThrowsError(try manager.switchAccount(to: "ghost")) { error in
            XCTAssertEqual(error as? AccountError, .accountNotFound("ghost"))
        }
    }

    func testRemoveCurrentAccountFallsBackToNext() throws {
        try manager.addAccount(name: "personal", apiKey: "key1")
        try manager.addAccount(name: "work", apiKey: "key2")
        try manager.removeAccount(name: "personal")
        XCTAssertEqual(try manager.currentAccountName(), "work")
        XCTAssertNil(mockStorage.stored["vash.account.personal"])
    }

    func testRemoveNonexistentAccountThrows() throws {
        XCTAssertThrowsError(try manager.removeAccount(name: "ghost")) { error in
            XCTAssertEqual(error as? AccountError, .accountNotFound("ghost"))
        }
    }

    func testRemoveLastAccountLeavesNoCurrentAccount() throws {
        try manager.addAccount(name: "solo", apiKey: "key1")
        try manager.removeAccount(name: "solo")
        XCTAssertNil(try manager.currentAccountName())
    }

    func testApiKeyResolvesCurrentAccount() throws {
        try manager.addAccount(name: "personal", apiKey: "secretkey")
        let key = try manager.apiKey()
        XCTAssertEqual(key, "secretkey")
    }

    func testApiKeyResolvesNamedAccount() throws {
        try manager.addAccount(name: "personal", apiKey: "key1")
        try manager.addAccount(name: "work", apiKey: "key2")
        let key = try manager.apiKey(for: "work")
        XCTAssertEqual(key, "key2")
    }

    func testApiKeyThrowsWhenNoCurrentAccount() throws {
        XCTAssertThrowsError(try manager.apiKey()) { error in
            XCTAssertEqual(error as? AccountError, .noCurrentAccount)
        }
    }

    func testApiKeyThrowsWhenAccountNotFound() throws {
        XCTAssertThrowsError(try manager.apiKey(for: "ghost")) { error in
            XCTAssertEqual(error as? AccountError, .accountNotFound("ghost"))
        }
    }
}
