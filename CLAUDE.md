# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```sh
make build        # debug build (swift build)
make release      # release build (swift build -c release)
make test         # run all tests (swift test)
make lint         # SwiftLint strict
make format       # SwiftFormat (Sources + Tests, swift 5.9)
make generate     # regenerate API client from openapi.yaml
make install      # build release + copy to /usr/local/bin/vash
```

Run a single test file or test case:
```sh
swift test --filter VashKitTests.AuthCommandTests
swift test --filter VashKitTests.AuthCommandTests/testLoginAddsAccount
```

## Architecture

Three targets:

- **`VasHostingClient`** — auto-generated at build time by `swift-openapi-generator` from `openapi.yaml`. Never edit `Sources/VasHostingClient/GeneratedSources/`. To change the API client, edit `openapi.yaml` and run `make generate`.
- **`VashKit`** — all CLI logic. Referenced as a library so it can be imported by tests without the executable entry point.
- **`vash`** — thin executable target; `Sources/vash/main.swift` calls `VashCommand.main()`.

### Key patterns

**Adding a command**: create a `*Command.swift` under `Sources/VashKit/Commands/<Group>/`, conforming to `AsyncParsableCommand`. Add `ClientOptions` for `--account`/`--format` options. Register it in the corresponding `*Group.swift`.

**`ClientOptions`** (`Sources/VashKit/Commands/ClientOptions.swift`) — mixin used by every API command. Exposes `account: String?` and `format: OutputFormat`. Call `clientOptions.makeClient()` to get an authenticated `Client` for the current/specified account.

**`AccountManager`** (`Sources/VashKit/Config/AccountManager.swift`) — reads `~/.vash/config.json` for account metadata; delegates API key storage to `SecureStorage` (Keychain on macOS, AES-256-GCM encrypted file on Linux).

**`OutputFormatter`** (`Sources/VashKit/Output/OutputFormatter.swift`) — use `printTable`, `printJSON`, `printSuccess`, and `printError` consistently. JSON errors go to stderr as `{"error":"<msg>","code":"<code>"}`. Error codes defined in `VashError.errorCode`.

**`VashError`** — four cases: `unauthorized`, `notFound`, `apiError`, `unexpectedStatus(Int)`.

### Testing

Tests inject `MockTransport` (a `ClientTransport`) and `MockSecureStorage` instead of real network/Keychain. Most command tests construct an `AccountManager` with an in-memory `MockSecureStorage` and a temp config directory.
