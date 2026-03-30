import XCTest
import VasHostingClient

/// Tests that our OpenAPI-defined schemas can decode real API response shapes.
final class ModelDecodingTests: XCTestCase {

    private let decoder = JSONDecoder()

    func testInvoiceDecoding() throws {
        let json = """
        {
            "3023000368": {
                "totalPrice": "0.00",
                "createdAt": "2023-01-17",
                "expiresAt": "2023-01-22"
            },
            "3023000370": {
                "totalPrice": "4414.08",
                "createdAt": "2023-01-17",
                "expiresAt": "2023-01-22"
            }
        }
        """.data(using: .utf8)!

        let response = try decoder.decode(Components.Schemas.UnpaidInvoicesResponse.self, from: json)
        XCTAssertEqual(response.additionalProperties.count, 2)
        XCTAssertEqual(response.additionalProperties["3023000368"]?.totalPrice, "0.00")
        XCTAssertEqual(response.additionalProperties["3023000370"]?.expiresAt, "2023-01-22")
    }

    func testDatabaseDecoding() throws {
        let json = """
        {
            "mydb_5579": {
                "user": "mydb.5579",
                "type": "mysql",
                "size": 100
            },
            "pgdb_5579": {
                "user": "pgdb_5579",
                "type": "postgresql",
                "size": 300
            }
        }
        """.data(using: .utf8)!

        let response = try decoder.decode(Components.Schemas.DatabasesResponse.self, from: json)
        XCTAssertEqual(response.additionalProperties.count, 2)
        XCTAssertEqual(response.additionalProperties["mydb_5579"]?._type, .mysql)
        XCTAssertEqual(response.additionalProperties["pgdb_5579"]?._type, .postgresql)
    }

    func testDNSRecordDecoding() throws {
        let json = """
        {
            "139816": {
                "name": "test.example.com",
                "type": "A",
                "content": "1.2.3.4",
                "priority": null,
                "ttl": 3600,
                "note": null,
                "created": "2023-01-01 00:00:00",
                "updated": "2023-06-01 00:00:00"
            }
        }
        """.data(using: .utf8)!

        let response = try decoder.decode(Components.Schemas.DNSRecordsResponse.self, from: json)
        XCTAssertEqual(response.additionalProperties.count, 1)
        let record = response.additionalProperties["139816"]
        XCTAssertEqual(record?.name, "test.example.com")
        XCTAssertEqual(record?._type, "A")
        XCTAssertEqual(record?.content, "1.2.3.4")
        XCTAssertEqual(record?.ttl, 3600)
        XCTAssertNil(record?.priority)
    }

    func testEmailAccountDecoding() throws {
        let json = """
        {
            "john": {
                "quota": 500,
                "isAutoReply": false,
                "isActive": true
            },
            "jane": {
                "quota": 0,
                "isAutoReply": true,
                "isActive": true
            }
        }
        """.data(using: .utf8)!

        let response = try decoder.decode(Components.Schemas.EmailAccountsResponse.self, from: json)
        XCTAssertEqual(response.additionalProperties.count, 2)
        XCTAssertEqual(response.additionalProperties["john"]?.quota, 500)
        XCTAssertEqual(response.additionalProperties["john"]?.isActive, true)
        XCTAssertEqual(response.additionalProperties["jane"]?.quota, 0)
        XCTAssertEqual(response.additionalProperties["jane"]?.isAutoReply, true)
    }

    func testServerDecoding() throws {
        let json = """
        {
            "srv01.example.com": {
                "id": 8367,
                "name": "my-server",
                "displayName": "My Production Server",
                "expiration": "2030-01-01",
                "tariff": "dedicated",
                "operatingSystem": "Debian 12",
                "storage": {"primary": 100000000000},
                "ram": 17179869184,
                "status": "active",
                "labels": ["production", "web"]
            }
        }
        """.data(using: .utf8)!

        let response = try decoder.decode(Components.Schemas.ServersResponse.self, from: json)
        let server = response.additionalProperties["srv01.example.com"]
        XCTAssertNotNil(server)
        XCTAssertEqual(server?.id, 8367)
        XCTAssertEqual(server?.name, "my-server")
        XCTAssertEqual(server?.status, "active")
        XCTAssertEqual(server?.labels, ["production", "web"])
    }

    func testServerLabelDecoding() throws {
        let json = """
        {
            "production": {"color": "#ff0000"},
            "staging": {"color": "#ffff00"}
        }
        """.data(using: .utf8)!

        let response = try decoder.decode(Components.Schemas.ServerLabelsResponse.self, from: json)
        XCTAssertEqual(response.additionalProperties.count, 2)
        XCTAssertEqual(response.additionalProperties["production"]?.color, "#ff0000")
    }

    func testOperatingSystemDecoding() throws {
        let json = """
        {
            "vpsc": {"name": "Current Debian with VPS Center", "distribution": "Debian"},
            "ubuntu": {"name": "Ubuntu 22.04", "distribution": "Ubuntu"}
        }
        """.data(using: .utf8)!

        let response = try decoder.decode(Components.Schemas.OperatingSystemsResponse.self, from: json)
        XCTAssertEqual(response.additionalProperties.count, 2)
        XCTAssertEqual(response.additionalProperties["vpsc"]?.distribution, "Debian")
    }

    func testFtpAccountDecoding() throws {
        let json = """
        {
            "ftpuser": {
                "quota": 1000,
                "isLocked": false,
                "directory": "/www"
            }
        }
        """.data(using: .utf8)!

        let response = try decoder.decode(Components.Schemas.FtpAccountsResponse.self, from: json)
        XCTAssertEqual(response.additionalProperties["ftpuser"]?.quota, 1000)
        XCTAssertEqual(response.additionalProperties["ftpuser"]?.isLocked, false)
        XCTAssertEqual(response.additionalProperties["ftpuser"]?.directory, "/www")
    }

    func testDomainInfoDecodesWithoutName() throws {
        let json = """
        {
            "id": 123,
            "expiration": "2026-12-31",
            "tariff": "basic"
        }
        """.data(using: .utf8)!

        let info = try decoder.decode(Components.Schemas.DomainInfo.self, from: json)
        XCTAssertEqual(info.id, 123)
        XCTAssertNil(info.name)
        XCTAssertEqual(info.expiration, "2026-12-31")
    }

    func testFtpAccountDecodesWithoutOptionalFields() throws {
        let json = """
        {
            "ftpuser": {
                "quota": 500
            }
        }
        """.data(using: .utf8)!

        let response = try decoder.decode(Components.Schemas.FtpAccountsResponse.self, from: json)
        XCTAssertEqual(response.additionalProperties["ftpuser"]?.quota, 500)
        XCTAssertNil(response.additionalProperties["ftpuser"]?.isLocked)
        XCTAssertNil(response.additionalProperties["ftpuser"]?.directory)
    }

    func testVdsDecoding() throws {
        let json = """
        {
            "vds01.example.com": {
                "id": 42,
                "name": "my-vds",
                "vpsCount": {"limit": 10, "used": 3, "free": 7},
                "storage": {
                    "primary": {"size": 1000, "used": 300, "free": 700}
                }
            }
        }
        """.data(using: .utf8)!

        let response = try decoder.decode(Components.Schemas.VdsResponse.self, from: json)
        let vds = response.additionalProperties["vds01.example.com"]
        XCTAssertNotNil(vds)
        XCTAssertEqual(vds?.id, 42)
        XCTAssertEqual(vds?.vpsCount?.limit, 10)
        XCTAssertEqual(vds?.vpsCount?.free, 7)
    }
}
