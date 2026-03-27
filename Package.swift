// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "vash",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "vash", targets: ["vash"]),
        .library(name: "VashKit", targets: ["VashKit"]),
        .library(name: "VasHostingClient", targets: ["VasHostingClient"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser.git",
            from: "1.5.0"
        ),
        .package(
            url: "https://github.com/apple/swift-openapi-generator.git",
            from: "1.6.0"
        ),
        .package(
            url: "https://github.com/apple/swift-openapi-runtime.git",
            from: "1.7.0"
        ),
        .package(
            url: "https://github.com/apple/swift-openapi-urlsession.git",
            from: "1.0.2"
        ),
        .package(
            url: "https://github.com/apple/swift-crypto.git",
            from: "3.0.0"
        ),
    ],
    targets: [
        // Auto-generated API client from OpenAPI spec
        .target(
            name: "VasHostingClient",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
            ]
        ),

        // Library with all CLI logic
        .target(
            name: "VashKit",
            dependencies: [
                "VasHostingClient",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "Crypto", package: "swift-crypto"),
            ]
        ),

        // Executable entry point
        .executableTarget(
            name: "vash",
            dependencies: [
                "VashKit",
            ]
        ),

        // Tests
        .testTarget(
            name: "VashKitTests",
            dependencies: [
                "VashKit",
                "VasHostingClient",
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
            ]
        ),
    ]
)
