import XCTest
@testable import VashKit
import Foundation

#if !canImport(Security)
final class EncryptedFileStorageTests: XCTestCase {
    private var tempDir: URL!
    private var storage: EncryptedFileStorage!

    override func setUp() {
        super.setUp()
        tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("VashStorageTests-\(UUID().uuidString)")
        // swiftlint:disable:next force_try
        try! FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        storage = EncryptedFileStorage(credentialsDirectory: tempDir)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
        super.tearDown()
    }

    func testStoreAndRetrieve() throws {
        try storage.store(key: "test-key", value: "secret-value")
        let retrieved = try storage.retrieve(key: "test-key")
        XCTAssertEqual(retrieved, "secret-value")
    }

    func testRetrieveNonexistentKeyReturnsNil() throws {
        let retrieved = try storage.retrieve(key: "nonexistent")
        XCTAssertNil(retrieved)
    }

    func testDeleteKey() throws {
        try storage.store(key: "key1", value: "value1")
        try storage.delete(key: "key1")
        XCTAssertNil(try storage.retrieve(key: "key1"))
    }

    func testListKeys() throws {
        try storage.store(key: "alpha", value: "v1")
        try storage.store(key: "beta", value: "v2")
        let keys = try storage.listKeys()
        XCTAssertEqual(keys.sorted(), ["alpha", "beta"])
    }

    func testUpdateExistingKey() throws {
        try storage.store(key: "key", value: "old-value")
        try storage.store(key: "key", value: "new-value")
        XCTAssertEqual(try storage.retrieve(key: "key"), "new-value")
    }

    func testEncryptedFileIsCreated() throws {
        try storage.store(key: "key", value: "value")
        let credFile = tempDir.appendingPathComponent("credentials.enc")
        XCTAssertTrue(FileManager.default.fileExists(atPath: credFile.path))
    }
}
#endif

#if canImport(Security)
final class KeychainStorageTests: XCTestCase {
    // Use unique keys to avoid conflicts with real keychain entries
    private let testPrefix = "vash.test.\(UUID().uuidString)"
    private var storage: KeychainStorage!

    override func setUp() {
        super.setUp()
        storage = KeychainStorage()
    }

    override func tearDown() {
        // Clean up test keys
        try? storage.delete(key: testKey("test1"))
        try? storage.delete(key: testKey("test2"))
        super.tearDown()
    }

    private func testKey(_ name: String) -> String {
        return "\(testPrefix).\(name)"
    }

    func testStoreAndRetrieve() throws {
        let key = testKey("test1")
        try storage.store(key: key, value: "my-secret")
        let retrieved = try storage.retrieve(key: key)
        XCTAssertEqual(retrieved, "my-secret")
    }

    func testRetrieveNonexistentKeyReturnsNil() throws {
        let retrieved = try storage.retrieve(key: testKey("nonexistent"))
        XCTAssertNil(retrieved)
    }

    func testDelete() throws {
        let key = testKey("test1")
        try storage.store(key: key, value: "value")
        try storage.delete(key: key)
        XCTAssertNil(try storage.retrieve(key: key))
    }

    func testUpdateExistingKey() throws {
        let key = testKey("test1")
        try storage.store(key: key, value: "old")
        try storage.store(key: key, value: "new")
        XCTAssertEqual(try storage.retrieve(key: key), "new")
    }
}
#endif
