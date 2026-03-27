# vash

**Command-line interface for [vas-hosting.cz](https://www.vas-hosting.cz)**

Manage your hosting account from the terminal — servers, domains, databases, DNS records, email accounts, FTP accounts, and more. Supports multiple named accounts, JSON output for scripting, and runs on macOS and Linux.

[![CI](https://github.com/jankoznarek/vas-hosting-cli/actions/workflows/ci.yml/badge.svg)](https://github.com/jankoznarek/vas-hosting-cli/actions/workflows/ci.yml)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey)
![Swift](https://img.shields.io/badge/swift-5.9%2B-orange)
![License](https://img.shields.io/badge/license-MIT-blue)

---

## Installation

### Homebrew (recommended)

```sh
brew tap jankoznarek/tap
brew install vash
```

### Build from source

Requires Swift 5.9+ (Xcode 15+ on macOS, or the [Swift toolchain](https://www.swift.org/download/) on Linux).

```sh
git clone https://github.com/jankoznarek/vas-hosting-cli.git
cd vas-hosting-cli
swift build -c release
sudo cp .build/release/vash /usr/local/bin/vash
```

---

## Quick start

**1. Get your API key** from the [vas-hosting.cz portal](https://portal.vas-hosting.cz) under Account → API.

**2. Add your account:**

```sh
vash auth login --name personal --api-key YOUR_API_KEY
```

**3. Start using it:**

```sh
vash server list
vash database list example.com
vash dns list example.com
```

---

## Account management

`vash` supports multiple named accounts. The current account is used by default; override it per-command with `--account`.

```sh
# Add accounts
vash auth login --name personal --api-key KEY1
vash auth login --name work     --api-key KEY2

# Manage accounts
vash auth list              # list all accounts
vash auth current           # show active account
vash auth switch work       # set active account
vash auth logout personal   # remove an account

# Override per command
vash server list --account work
```

---

## Commands

Global options available on all API commands:

| Option | Description |
|--------|-------------|
| `--account <name>` | Use a specific account (overrides current) |
| `--format table\|json` | Output format — `table` (default) or `json` |

### auth

```sh
vash auth login --name <name> --api-key <key>
vash auth logout <name>
vash auth list
vash auth switch <name>
vash auth current
```

### account

```sh
vash account invoices                              # list unpaid invoices
vash account pay-invoice --invoice-id <id>         # pay an invoice
```

### domain

```sh
vash domain info <domain>                          # domain details
vash domain change-php <domain> --version <ver>    # change PHP version
```

### database

```sh
vash database list <domain>
vash database create <domain> --name <db> --type mysql|postgresql --password <pass>
vash database change-password <domain> --name <db> --password <pass>
vash database backup <domain> --name <db>
vash database delete <domain> --name <db>
```

### dns

```sh
vash dns list <domain>
vash dns create <domain> --name <record> --type A|CNAME|MX|TXT|... --content <val> --ttl <secs>
vash dns edit <domain> <record-id> --content <val> --ttl <secs>
vash dns delete <domain> <record-id>
```

### email

```sh
vash email list <domain>
vash email create <domain> --name <user> --display-name <name> --password <pass>
vash email change-password <domain> --name <user> --password <pass>
vash email change-quota <domain> --name <user> --quota <mb>
vash email create-alias <domain> --name <user> --alias <alias>
vash email delete-alias <domain> --name <user> --alias <alias>
vash email auto-reply <domain> --name <user> --message <msg> --enable|--disable
vash email forwarding <domain> --name <user> --forward-to <addr>
vash email delete <domain> --name <user>
```

### ftp

```sh
vash ftp list <domain>
vash ftp create <domain> --name <user> --password <pass>
vash ftp change-password <domain> --name <user> --password <pass>
vash ftp change-quota <domain> --name <user> --quota <mb>
vash ftp lock <domain> --name <user>
vash ftp unlock <domain> --name <user>
vash ftp delete <domain> --name <user>
```

### server

```sh
vash server list
vash server info <hostname>
vash server reboot <hostname>
vash server list-vds
vash server install-vps <hostname> --os <key> --vds <vds-hostname>
vash server assign-label <hostname> --label <label>
vash server unassign-label <hostname> --label <label>
```

### server-label

```sh
vash server-label list
vash server-label create --name <label> --color <hex>
vash server-label edit --name <label> --color <hex>
vash server-label delete --name <label>
```

### infrastructure

```sh
vash infrastructure list-os      # available operating systems
vash infrastructure list-ips     # available IP addresses
```

---

## Examples

```sh
# List servers, output as JSON for scripting
vash server list --format json | jq '.[] | select(.status == "active")'

# Create a DNS record
vash dns create example.com --name www --type A --content 1.2.3.4 --ttl 3600

# Create a MySQL database
vash database create example.com --name myapp --type mysql --password secretpass

# Check unpaid invoices on a secondary account
vash account invoices --account work

# List email accounts
vash email list example.com

# Reboot a server
vash server reboot srv01.example.com
```

---

## Secure credential storage

API keys are stored securely — never in plain text.

| Platform | Storage |
|----------|---------|
| macOS | macOS Keychain (`cz.vas-hosting.cli`) |
| Linux | AES-256-GCM encrypted file at `~/.vash/credentials.enc`, key derived from machine ID |

Account configuration is stored in `~/.vash/config.json`.

---

## Development

```sh
swift build           # debug build
swift build -c release  # release build
swift test            # run all 63 tests
swiftlint lint --strict Sources/ Tests/  # lint
```

The API client is auto-generated at build time from `openapi.yaml` using [swift-openapi-generator](https://github.com/apple/swift-openapi-generator). To update the client, edit `openapi.yaml` and rebuild — no manual model code needed.

---

## License

MIT
