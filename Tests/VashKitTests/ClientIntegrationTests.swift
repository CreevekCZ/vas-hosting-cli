import XCTest
import OpenAPIRuntime
import HTTPTypes
import Foundation
@testable import VashKit
import VasHostingClient

/// Integration tests that wire the generated Client + AuthMiddleware + MockTransport together.
final class ClientIntegrationTests: XCTestCase {

    private typealias TransportHandler = @Sendable (HTTPRequest, HTTPBody?, URL, String) async throws -> (HTTPResponse, HTTPBody?)

    private func makeClient(apiKey: String = "test-key", responding handler: @escaping TransportHandler) throws -> Client {
        try Client(
            serverURL: Servers.Server1.url(),
            transport: MockTransport(handler: handler),
            middlewares: [AuthMiddleware(apiKey: apiKey)]
        )
    }

    // MARK: - Auth header injection

    func testApiKeyHeaderIsInjectedOnEveryRequest() async throws {
        var capturedRequest: HTTPRequest?
        let client = try makeClient(apiKey: "my-secret-key") { request, _, _, _ in
            capturedRequest = request
            let json = #"{"3023000368": {"totalPrice": "0.00", "createdAt": "2023-01-17", "expiresAt": "2023-01-22"}}"#
            return (HTTPResponse(status: .ok), HTTPBody(Data(json.utf8)))
        }

        _ = try await client.listUnpaidInvoices()
        XCTAssertEqual(capturedRequest?.headerFields[HTTPField.Name("X-API-Key")!], "my-secret-key")
    }

    // MARK: - Invoices

    func testListUnpaidInvoicesDecodesResponse() async throws {
        let client = try makeClient { _, _, _, _ in
            let json = """
            {
                "3023000368": {"totalPrice": "0.00", "createdAt": "2023-01-17", "expiresAt": "2023-01-22"},
                "3023000370": {"totalPrice": "4414.08", "createdAt": "2023-01-17", "expiresAt": "2023-01-22"}
            }
            """
            return (HTTPResponse(status: .ok), HTTPBody(Data(json.utf8)))
        }

        let response = try await client.listUnpaidInvoices()
        guard case .ok(let ok) = response, case .json(let invoices) = ok.body else {
            return XCTFail("Expected ok JSON response")
        }
        XCTAssertEqual(invoices.additionalProperties.count, 2)
        XCTAssertEqual(invoices.additionalProperties["3023000368"]?.totalPrice, "0.00")
        XCTAssertEqual(invoices.additionalProperties["3023000370"]?.totalPrice, "4414.08")
    }

    // MARK: - Databases

    func testListDatabasesDecodesResponse() async throws {
        let client = try makeClient { _, _, _, _ in
            let json = """
            {
                "mydb_5579": {"user": "mydb.5579", "type": "mysql", "size": 100},
                "pgdb_5579": {"user": "pgdb_5579", "type": "postgresql", "size": 300}
            }
            """
            return (HTTPResponse(status: .ok), HTTPBody(Data(json.utf8)))
        }

        let response = try await client.listDatabases(path: .init(domain: "example.com"))
        guard case .ok(let ok) = response, case .json(let dbs) = ok.body else {
            return XCTFail("Expected ok JSON response")
        }
        XCTAssertEqual(dbs.additionalProperties.count, 2)
        XCTAssertEqual(dbs.additionalProperties["mydb_5579"]?._type, .mysql)
        XCTAssertEqual(dbs.additionalProperties["pgdb_5579"]?._type, .postgresql)
    }

    // MARK: - DNS

    func testListDNSRecordsDecodesResponse() async throws {
        let client = try makeClient { _, _, _, _ in
            let json = """
            {
                "139816": {
                    "name": "test.example.com", "type": "A", "content": "1.2.3.4",
                    "priority": null, "ttl": 3600, "note": null,
                    "created": "2023-01-01 00:00:00", "updated": "2023-06-01 00:00:00"
                }
            }
            """
            return (HTTPResponse(status: .ok), HTTPBody(Data(json.utf8)))
        }

        let response = try await client.listDnsRecords(path: .init(domain: "example.com"))
        guard case .ok(let ok) = response, case .json(let records) = ok.body else {
            return XCTFail("Expected ok JSON response")
        }
        XCTAssertEqual(records.additionalProperties["139816"]?.name, "test.example.com")
        XCTAssertEqual(records.additionalProperties["139816"]?.ttl, 3600)
    }

    // MARK: - Mutation returns 204

    func testCreateDatabaseReturns204() async throws {
        let client = try makeClient { _, _, _, _ in
            (HTTPResponse(status: .noContent), nil)
        }

        let response = try await client.createDatabase(
            path: .init(domain: "example.com"),
            body: .json(.init(name: "testdb", _type: .mysql, password: "secret123", encoding: nil, note: nil))
        )
        if case .noContent = response { /* pass */ } else {
            XCTFail("Expected noContent response")
        }
    }

    // MARK: - Servers

    func testListServersDecodesResponse() async throws {
        let client = try makeClient { _, _, _, _ in
            let json = """
            {
                "srv01.example.com": {
                    "id": 8367, "name": "my-server", "displayName": "My Server",
                    "expiration": "2030-01-01", "tariff": "dedicated",
                    "operatingSystem": "Debian 12",
                    "storage": {"primary": 100000000000},
                    "ram": 17179869184,
                    "status": "active", "labels": []
                }
            }
            """
            return (HTTPResponse(status: .ok), HTTPBody(Data(json.utf8)))
        }

        let response = try await client.listServers()
        guard case .ok(let ok) = response, case .json(let servers) = ok.body else {
            return XCTFail("Expected ok JSON response")
        }
        XCTAssertEqual(servers.additionalProperties["srv01.example.com"]?.id, 8367)
        XCTAssertEqual(servers.additionalProperties["srv01.example.com"]?.status, "active")
    }

    // MARK: - Unauthorized propagation

    func testUnauthorizedResponsePropagated() async throws {
        let client = try makeClient { _, _, _, _ in
            let json = #"{"message": "Invalid API key"}"#
            return (HTTPResponse(status: .unauthorized), HTTPBody(Data(json.utf8)))
        }

        let response = try await client.listUnpaidInvoices()
        if case .unauthorized = response { /* pass */ } else {
            XCTFail("Expected unauthorized response")
        }
    }
}
