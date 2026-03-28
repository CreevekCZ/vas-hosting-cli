import Foundation
import OpenAPIRuntime
import HTTPTypes

/// Middleware that rewrites empty JSON arrays `[]` to empty objects `{}` in API responses.
///
/// The vas-hosting.cz API is PHP-based and serializes empty associative arrays as `[]`
/// instead of `{}`. Since the OpenAPI spec (correctly) defines these responses as objects
/// with `additionalProperties`, the generated decoder fails on `[]`. This middleware
/// transparently fixes the mismatch.
public struct EmptyArrayRewriteMiddleware: ClientMiddleware, Sendable {
    public init() {}

    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        let (response, responseBody) = try await next(request, body, baseURL)
        guard let responseBody else { return (response, nil) }

        let data = try await Data(collecting: responseBody, upTo: .max)

        // Fast path: top-level empty array → empty object
        let trimmed = data.trimmingASCIIWhitespace
        if trimmed == Data("[]".utf8) {
            return (response, HTTPBody(Data("{}".utf8)))
        }

        // Fix nested empty arrays that should be objects (e.g. "ipv4": [] in IpAddressesResponse).
        // Only rewrite fields known to be objects per the OpenAPI spec; leave real arrays alone.
        let objectFields = Self.nestedObjectFields[operationID]
        if let objectFields,
           let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            var fixed = jsonObject
            var modified = false
            for key in objectFields {
                if let arr = jsonObject[key] as? [Any], arr.isEmpty {
                    fixed[key] = [String: Any]()
                    modified = true
                }
            }
            if modified {
                let fixedData = try JSONSerialization.data(withJSONObject: fixed)
                return (response, HTTPBody(fixedData))
            }
        }

        return (response, HTTPBody(data))
    }
}

extension EmptyArrayRewriteMiddleware {
    /// Maps operationID → set of top-level JSON keys that are objects (not arrays)
    /// and may be returned as `[]` by the PHP API when empty.
    static let nestedObjectFields: [String: Set<String>] = [
        "listIpAddresses": ["ipv4"],
        "getServerInfo": ["ipv4"],
    ]
}

private extension Data {
    var trimmingASCIIWhitespace: Data {
        let whitespace: Set<UInt8> = [0x20, 0x09, 0x0A, 0x0D] // space, tab, LF, CR
        guard let start = firstIndex(where: { !whitespace.contains($0) }),
              let end = lastIndex(where: { !whitespace.contains($0) }) else {
            return Data()
        }
        return self[start...end]
    }
}
