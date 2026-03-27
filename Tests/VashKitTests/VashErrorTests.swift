import XCTest
@testable import VashKit

final class VashErrorTests: XCTestCase {

    func testUnauthorizedErrorCode() {
        XCTAssertEqual(VashError.unauthorized("msg").errorCode, "unauthorized")
    }

    func testNotFoundErrorCode() {
        XCTAssertEqual(VashError.notFound("msg").errorCode, "not_found")
    }

    func testApiErrorCode() {
        XCTAssertEqual(VashError.apiError("msg").errorCode, "api_error")
    }

    func testUnexpectedStatusErrorCode() {
        XCTAssertEqual(VashError.unexpectedStatus(500).errorCode, "unexpected_status")
    }

    func testUnauthorizedErrorDescription() {
        XCTAssertEqual(VashError.unauthorized("Bad key").errorDescription, "Bad key")
    }

    func testNotFoundErrorDescription() {
        XCTAssertEqual(VashError.notFound("Not here").errorDescription, "Not here")
    }

    func testApiErrorDescription() {
        XCTAssertEqual(VashError.apiError("Conflict").errorDescription, "Conflict")
    }

    func testUnexpectedStatusErrorDescription() {
        XCTAssertEqual(VashError.unexpectedStatus(503).errorDescription, "Unexpected HTTP status: 503")
    }
}
