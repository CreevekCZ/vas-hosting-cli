# vash

**Command-line interface for [vas-hosting.cz](https://www.vas-hosting.cz)**

Manage your hosting account from the terminal — servers, domains, databases, DNS records, email accounts, FTP accounts, and more. Supports multiple named accounts, JSON output for scripting, and runs on macOS and Linux.

[![CI](https://github.com/CreevekCZ/vas-hosting-cli/actions/workflows/ci.yml/badge.svg)](https://github.com/CreevekCZ/vas-hosting-cli/actions/workflows/ci.yml)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey)
![Swift](https://img.shields.io/badge/swift-5.9%2B-orange)
![License](https://img.shields.io/badge/license-MIT-blue)

> Czech version: [README.cs.md](README.cs.md)

---

## Installation

### Homebrew (recommended)

```sh
brew tap CreevekCZ/tap
brew install vash
```

Shell completions (zsh, bash, fish) are installed automatically.

### Build from source

Requires Swift 5.9+ (Xcode 15+ on macOS, or the [Swift toolchain](https://www.swift.org/download/) on Linux).

```sh
git clone https://github.com/CreevekCZ/vas-hosting-cli.git
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
vash account pay-invoice <variableSymbol>          # pay an invoice with credit
```

### domain

```sh
vash domain info <domain>                          # domain details
vash domain change-php <domain> --version <ver>    # change PHP version
```

### database

```sh
vash database list <domain>
vash database create <domain> --name <db> --type mysql|postgresql --password <pass> [--encoding <enc>] [--note <note>]
vash database change-password <domain> <database> --password <pass>
vash database backup <domain> <database>
vash database delete <domain> <database>
```

### dns

```sh
vash dns list <domain>
vash dns create <domain> --name <record> --type A|AAAA|CNAME|MX|TXT|NS|SRV|CAA --content <val> --ttl <secs> [--priority <n>]
vash dns edit <domain> <record-id> --name <record> --type <type> --content <val> --ttl <secs>
vash dns delete <domain> <record-id>
```

### email

```sh
vash email list <domain>
vash email create <domain> --name <user> --display-name <name> --password <pass> [--quota <mb>]
vash email change-password <domain> <email> --password <pass>
vash email change-quota <domain> <email> --quota <mb>
vash email create-alias <domain> <email> --alias <alias>
vash email delete-alias <domain> <email> --alias <alias>
vash email auto-reply <domain> <email> --enabled true|false [--subject <s>] [--message <m>]
vash email forwarding <domain> <email> --forward-to <addr>
vash email delete <domain> <email>
```

### ftp

```sh
vash ftp list <domain>
vash ftp create <domain> --name <user> --directory <dir> --password <pass> [--quota <mb>]
vash ftp change-password <domain> <ftp> --password <pass>
vash ftp change-quota <domain> <ftp> --quota <mb>
vash ftp lock <domain> <ftp>
vash ftp unlock <domain> <ftp>
vash ftp delete <domain> <ftp>
```

### server

```sh
vash server list [--labels <label1,label2>]
vash server info <hostname>
vash server reboot <hostname>
vash server list-vds
vash server install-vps <hostname> --cpu <mhz> --ram <gib> --storage-size <gb> --storage-location <slot> --os <id> [--server-name <n>] [--ip-address <ip>]
vash server assign-label <hostname> --label <label>
vash server unassign-label <hostname> --label <label>
```

### server-label

```sh
vash server-label list
vash server-label create --name <label> [--color <hex>]
vash server-label edit <name> --new-name <n> [--color <hex>]
vash server-label delete <name>
```

### infrastructure

```sh
vash infrastructure list-os      # available operating systems (use ID with install-vps --os)
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

# Reboot a server
vash server reboot srv01.example.com
```

---

## Using vash with AI agents

The [`agents/`](agents/) directory contains skill files that teach AI coding assistants how to use `vash`. Install the skill for your agent and it will understand every command, flag, and workflow without you having to explain them.

### Claude Code

```sh
mkdir -p .claude/commands
curl -o .claude/commands/vash.md \
  https://raw.githubusercontent.com/CreevekCZ/vas-hosting-cli/main/agents/claude-code/vash.md
```

Then type `/vash` in Claude Code to activate the skill. Claude will know the full command reference and can generate, explain, or run `vash` commands on your behalf.

More agents (Cursor, Codex, etc.) will be added to the [`agents/`](agents/) directory over time.

---

## Secure credential storage

API keys are stored securely — never in plain text.

| Platform | Storage |
|----------|---------|
| macOS | macOS Keychain |
| Linux / WSL | AES-256-GCM encrypted file at `~/.vash/credentials.enc` |

Account configuration is stored in `~/.vash/config.json`.

---

## Development

```sh
make build    # debug build
make release  # release build
make test     # run all tests
make lint     # SwiftLint strict
make format   # SwiftFormat
make generate # regenerate API client from openapi.yaml
make install  # build release + install to /usr/local/bin/vash
```

The API client is auto-generated at build time from `openapi.yaml` using [swift-openapi-generator](https://github.com/apple/swift-openapi-generator). To update the client, edit `openapi.yaml` and run `make generate`.

---

## License

MIT
