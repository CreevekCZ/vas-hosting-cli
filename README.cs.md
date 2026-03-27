# vash

**Nástroj příkazové řádky pro [vas-hosting.cz](https://www.vas-hosting.cz)**

Spravujte svůj hosting z terminálu — servery, domény, databáze, DNS záznamy, e-mailové účty, FTP účty a další. Podporuje více pojmenovaných účtů, JSON výstup pro skripty a běží na macOS i Linuxu.

[![CI](https://github.com/CreevekCZ/vas-hosting-cli/actions/workflows/ci.yml/badge.svg)](https://github.com/CreevekCZ/vas-hosting-cli/actions/workflows/ci.yml)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey)
![Swift](https://img.shields.io/badge/swift-5.9%2B-orange)
![License](https://img.shields.io/badge/license-MIT-blue)

> English version: [README.md](README.md)

---

## Instalace

### Homebrew (doporučeno)

```sh
brew tap CreevekCZ/tap
brew install vash
```

Doplňování příkazů v shellu (zsh, bash, fish) se nainstaluje automaticky.

### Sestavení ze zdrojového kódu

Vyžaduje Swift 5.9+ (Xcode 15+ na macOS, nebo [Swift toolchain](https://www.swift.org/download/) na Linuxu).

```sh
git clone https://github.com/CreevekCZ/vas-hosting-cli.git
cd vas-hosting-cli
swift build -c release
sudo cp .build/release/vash /usr/local/bin/vash
```

---

## Rychlý start

**1. Získejte API klíč** z [portálu vas-hosting.cz](https://portal.vas-hosting.cz) v sekci Účet → API.

**2. Přidejte svůj účet:**

```sh
vash auth login --name personal --api-key VÁŠ_API_KLÍČ
```

**3. Začněte používat:**

```sh
vash server list
vash database list example.com
vash dns list example.com
```

---

## Správa účtů

`vash` podporuje více pojmenovaných účtů. Výchozí účet se používá automaticky; pro konkrétní příkaz ho lze přepsat pomocí `--account`.

```sh
# Přidání účtů
vash auth login --name personal --api-key KLÍČ1
vash auth login --name work     --api-key KLÍČ2

# Správa účtů
vash auth list              # seznam všech účtů
vash auth current           # zobrazit aktivní účet
vash auth switch work       # přepnout aktivní účet
vash auth logout personal   # odebrat účet

# Přepnutí pro konkrétní příkaz
vash server list --account work
```

---

## Příkazy

Globální volby dostupné pro všechny API příkazy:

| Volba | Popis |
|-------|-------|
| `--account <name>` | Použít konkrétní účet (přepíše výchozí) |
| `--format table\|json` | Formát výstupu — `table` (výchozí) nebo `json` |

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
vash account invoices                              # seznam nezaplacených faktur
vash account pay-invoice <variableSymbol>          # zaplatit fakturu kreditem
```

### domain

```sh
vash domain info <domain>                          # informace o doméně
vash domain change-php <domain> --version <ver>    # změna verze PHP
```

### database

```sh
vash database list <domain>
vash database create <domain> --name <db> --type mysql|postgresql --password <pass> [--encoding <enc>] [--note <pozn>]
vash database change-password <domain> <database> --password <pass>
vash database backup <domain> <database>
vash database delete <domain> <database>
```

### dns

```sh
vash dns list <domain>
vash dns create <domain> --name <záznam> --type A|AAAA|CNAME|MX|TXT|NS|SRV|CAA --content <hodnota> --ttl <sekundy> [--priority <n>]
vash dns edit <domain> <record-id> --name <záznam> --type <typ> --content <hodnota> --ttl <sekundy>
vash dns delete <domain> <record-id>
```

### email

```sh
vash email list <domain>
vash email create <domain> --name <uživatel> --display-name <jméno> --password <pass> [--quota <mb>]
vash email change-password <domain> <email> --password <pass>
vash email change-quota <domain> <email> --quota <mb>
vash email create-alias <domain> <email> --alias <alias>
vash email delete-alias <domain> <email> --alias <alias>
vash email auto-reply <domain> <email> --enabled true|false [--subject <předmět>] [--message <zpráva>]
vash email forwarding <domain> <email> --forward-to <adresa>
vash email delete <domain> <email>
```

### ftp

```sh
vash ftp list <domain>
vash ftp create <domain> --name <uživatel> --directory <adresář> --password <pass> [--quota <mb>]
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
vash infrastructure list-os      # dostupné operační systémy (ID použijte s install-vps --os)
vash infrastructure list-ips     # dostupné IP adresy
```

---

## Příklady

```sh
# Seznam serverů jako JSON pro skripty
vash server list --format json | jq '.[] | select(.status == "active")'

# Vytvoření DNS záznamu
vash dns create example.com --name www --type A --content 1.2.3.4 --ttl 3600

# Vytvoření MySQL databáze
vash database create example.com --name myapp --type mysql --password tajnyheslo

# Kontrola nezaplacených faktur na druhém účtu
vash account invoices --account work

# Restart serveru
vash server reboot srv01.example.com
```

---

## Použití vash s AI agenty

Složka [`agents/`](agents/) obsahuje soubory dovedností, které naučí AI asistenty používat `vash`. Nainstalujte soubor pro svého agenta a ten bude znát všechny příkazy, přepínače a postupy, aniž byste mu je museli vysvětlovat.

### Claude Code

```sh
mkdir -p .claude/commands
curl -o .claude/commands/vash.md \
  https://raw.githubusercontent.com/CreevekCZ/vas-hosting-cli/main/agents/claude-code/vash.md
```

Poté zadejte `/vash` v Claude Code pro aktivaci dovednosti. Claude bude znát kompletní referenci příkazů a může generovat, vysvětlovat nebo spouštět příkazy `vash` za vás.

Podpora dalších agentů (Cursor, Codex atd.) bude postupně přidávána do složky [`agents/`](agents/).

---

## Bezpečné ukládání přístupových údajů

API klíče jsou ukládány bezpečně — nikdy jako prostý text.

| Platforma | Úložiště |
|-----------|----------|
| macOS | macOS Keychain |
| Linux / WSL | AES-256-GCM šifrovaný soubor v `~/.vash/credentials.enc` |

Konfigurace účtů je uložena v `~/.vash/config.json`.

---

## Vývoj

```sh
make build    # debug sestavení
make release  # release sestavení
make test     # spuštění všech testů
make lint     # SwiftLint strict
make format   # SwiftFormat
make generate # přegenerování API klienta z openapi.yaml
make install  # release sestavení + instalace do /usr/local/bin/vash
```

API klient je automaticky generován při sestavení z `openapi.yaml` pomocí [swift-openapi-generator](https://github.com/apple/swift-openapi-generator). Pro aktualizaci klienta upravte `openapi.yaml` a spusťte `make generate`.

---

## Licence

MIT
