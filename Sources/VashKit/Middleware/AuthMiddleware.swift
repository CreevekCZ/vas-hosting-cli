import Foundation
import OpenAPIRuntime
import HTTPTypes

/// Middleware that injects the X-API-Key header into every outgoing request.
public struct AuthMiddleware: ClientMiddleware, Sendable {
    private let apiKey: String

    public init(apiKey: String) {
        self.apiKey = apiKey
    }

    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var modifiedRequest = request
        modifiedRequest.headerFields[.init("X-API-Key")!] = apiKey
        return try await next(modifiedRequest, body, baseURL)
    }
}
