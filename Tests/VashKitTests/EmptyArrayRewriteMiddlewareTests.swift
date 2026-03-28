import XCTest
import OpenAPIRuntime
import HTTPTypes
@testable import VashKit

final class EmptyArrayRewriteMiddlewareTests: XCTestCase {

    private let middleware = EmptyArrayRewriteMiddleware()
    private let dummyRequest = HTTPRequest(method: .get, scheme: "https", authority: "example.com", path: "/test")
    private let baseURL = URL(string: "https://example.com")!

    private func makeNext(responseBody: Data) -> @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?) {
        return { _, _, _ in
            let response = HTTPResponse(status: .ok)
            return (response, HTTPBody(responseBody))
        }
    }

    // MARK: - Top-level empty array

    func testEmptyArrayRewrittenToEmptyObject() async throws {
        let next = makeNext(responseBody: Data("[]".utf8))
        let (_, body) = try await middleware.intercept(
            dummyRequest, body: nil, baseURL: baseURL, operationID: "listServers", next: next
        )
        let data = try await Data(collecting: body!, upTo: .max)
        XCTAssertEqual(String(data: data, encoding: .utf8), "{}")
    }

    func testEmptyArrayWithWhitespaceRewrittenToEmptyObject() async throws {
        let next = makeNext(responseBody: Data("  []\n".utf8))
        let (_, body) = try await middleware.intercept(
            dummyRequest, body: nil, baseURL: baseURL, operationID: "listServers", next: next
        )
        let data = try await Data(collecting: body!, upTo: .max)
        XCTAssertEqual(String(data: data, encoding: .utf8), "{}")
    }

    // MARK: - Normal responses pass through

    func testPopulatedObjectPassesThrough() async throws {
        let original = """
        {"srv01": {"id": 1, "name": "test", "expiration": "2030-01-01", "tariff": "vps", "status": "active"}}
        """
        let next = makeNext(responseBody: Data(original.utf8))
        let (_, body) = try await middleware.intercept(
            dummyRequest, body: nil, baseURL: baseURL, operationID: "listServers", next: next
        )
        let data = try await Data(collecting: body!, upTo: .max)
        XCTAssertEqual(String(data: data, encoding: .utf8), original)
    }

    func testEmptyObjectPassesThrough() async throws {
        let next = makeNext(responseBody: Data("{}".utf8))
        let (_, body) = try await middleware.intercept(
            dummyRequest, body: nil, baseURL: baseURL, operationID: "listServers", next: next
        )
        let data = try await Data(collecting: body!, upTo: .max)
        XCTAssertEqual(String(data: data, encoding: .utf8), "{}")
    }

    // MARK: - Nested empty array fix

    func testNestedEmptyArrayRewrittenForKnownObjectFields() async throws {
        let original = """
        {"ipv4": [], "ipv6": []}
        """
        let next = makeNext(responseBody: Data(original.utf8))
        let (_, body) = try await middleware.intercept(
            dummyRequest, body: nil, baseURL: baseURL, operationID: "listIpAddresses", next: next
        )
        let data = try await Data(collecting: body!, upTo: .max)
        let parsed = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        XCTAssertTrue(parsed["ipv4"] is [String: Any], "ipv4 should be rewritten to an object")
        XCTAssertTrue(parsed["ipv6"] is [Any], "ipv6 is a real array and should NOT be rewritten")
    }

    func testNestedPopulatedObjectFieldNotRewritten() async throws {
        let original = """
        {"ipv4": {"1.2.3.4": {"reverse": "host.example.com"}}, "ipv6": []}
        """
        let next = makeNext(responseBody: Data(original.utf8))
        let (_, body) = try await middleware.intercept(
            dummyRequest, body: nil, baseURL: baseURL, operationID: "listIpAddresses", next: next
        )
        let data = try await Data(collecting: body!, upTo: .max)
        let parsed = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        XCTAssertTrue(parsed["ipv4"] is [String: Any])
        let ipv4 = parsed["ipv4"] as? [String: Any] ?? [:]
        XCTAssertNotNil(ipv4["1.2.3.4"], "populated ipv4 data should be preserved")
    }

    func testNestedRewriteOnlyAppliesToKnownOperations() async throws {
        let original = """
        {"someField": []}
        """
        let next = makeNext(responseBody: Data(original.utf8))
        let (_, body) = try await middleware.intercept(
            dummyRequest, body: nil, baseURL: baseURL, operationID: "unknownOperation", next: next
        )
        let data = try await Data(collecting: body!, upTo: .max)
        let parsed = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        XCTAssertTrue(parsed["someField"] is [Any], "should not rewrite for unknown operations")
    }

    // MARK: - Nil body

    func testNilBodyPassesThrough() async throws {
        let next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?) = { _, _, _ in
            (HTTPResponse(status: .noContent), nil)
        }
        let (response, body) = try await middleware.intercept(
            dummyRequest, body: nil, baseURL: baseURL, operationID: "test", next: next
        )
        XCTAssertEqual(response.status, .noContent)
        XCTAssertNil(body)
    }
}
