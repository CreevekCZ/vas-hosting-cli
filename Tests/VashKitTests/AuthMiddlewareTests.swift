import XCTest
@testable import VashKit
import OpenAPIRuntime
import HTTPTypes
import Foundation

final class AuthMiddlewareTests: XCTestCase {

    func testMiddlewareInjectsApiKeyHeader() async throws {
        let middleware = AuthMiddleware(apiKey: "test-api-key-123")
        var capturedRequest: HTTPRequest?

        let result = try await middleware.intercept(
            HTTPRequest(method: .get, scheme: "https", authority: "portal.vas-hosting.cz", path: "/api/v1/account/unpaid-invoices"),
            body: nil,
            baseURL: URL(string: "https://portal.vas-hosting.cz")!,
            operationID: "listUnpaidInvoices"
        ) { request, _, _ in
            capturedRequest = request
            return (HTTPResponse(status: .ok), nil)
        }

        XCTAssertNotNil(capturedRequest)
        XCTAssertEqual(capturedRequest?.headerFields[HTTPField.Name("X-API-Key")!], "test-api-key-123")
        XCTAssertEqual(result.0.status, .ok)
    }

    func testMiddlewarePreservesOtherHeaders() async throws {
        let middleware = AuthMiddleware(apiKey: "my-key")

        var request = HTTPRequest(method: .get, scheme: "https", authority: "portal.vas-hosting.cz", path: "/api/v1/test")
        request.headerFields[.accept] = "application/json"

        var capturedRequest: HTTPRequest?
        _ = try await middleware.intercept(
            request, body: nil,
            baseURL: URL(string: "https://portal.vas-hosting.cz")!,
            operationID: "test"
        ) { req, _, _ in
            capturedRequest = req
            return (HTTPResponse(status: .ok), nil)
        }

        XCTAssertEqual(capturedRequest?.headerFields[HTTPField.Name("X-API-Key")!], "my-key")
        XCTAssertEqual(capturedRequest?.headerFields[.accept], "application/json")
    }
}
