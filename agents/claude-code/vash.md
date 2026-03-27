# vash — vas-hosting.cz CLI skill

Use the `vash` CLI to manage vas-hosting.cz hosting services. Always prefer `--format json` when reading output programmatically.

## Authentication

```sh
vash auth login --name <alias> --api-key <key>   # add account
vash auth list                                    # list accounts
vash auth switch <name>                           # switch active account
vash auth current                                 # show active account
vash auth logout <name>                           # remove account
```

Override account per-command: `--account <name>`

## account

```sh
vash account invoices
vash account pay-invoice <variableSymbol>
```

## domain

```sh
vash domain info <domain>
vash domain change-php <domain> --version <version>
```

## database

```sh
vash database list <domain>
vash database create <domain> --name <n> --type <mysql|postgresql> --password <pass> [--encoding <enc>] [--note <note>]
vash database change-password <domain> <database> --password <pass>
vash database backup <domain> <database>
vash database delete <domain> <database>
```

## dns

```sh
vash dns list <domain>
vash dns create <domain> --name <n> --type <A|AAAA|CNAME|MX|TXT|NS|SRV|CAA> --content <v> --ttl <seconds> [--priority <n>]
vash dns edit <domain> <recordId> --name <n> --type <t> --content <v> --ttl <seconds> [--priority <n>]
vash dns delete <domain> <recordId>
```

## email

```sh
vash email list <domain>
vash email create <domain> --name <n> --display-name <n> --password <pass> [--quota <mb>]
vash email change-password <domain> <email> --password <pass>
vash email change-quota <domain> <email> --quota <mb>
vash email create-alias <domain> <email> --alias <alias>
vash email delete-alias <domain> <email> --alias <alias>
vash email auto-reply <domain> <email> --enabled <true|false> [--subject <s>] [--message <m>]
vash email forwarding <domain> <email> --forward-to <address>
vash email delete <domain> <email>
```

## ftp

```sh
vash ftp list <domain>
vash ftp create <domain> --name <n> --directory <dir> --password <pass> [--quota <mb>]
vash ftp change-password <domain> <ftp> --password <pass>
vash ftp change-quota <domain> <ftp> --quota <mb>
vash ftp lock <domain> <ftp>
vash ftp unlock <domain> <ftp>
vash ftp delete <domain> <ftp>
```

## server

```sh
vash server list [--labels <label1,label2>]
vash server info <hostname>
vash server reboot <hostname>
vash server list-vds
vash server install-vps <hostname> --cpu <mhz> --ram <gib> --storage-size <gb> --storage-location <slot> --os <id> [--server-name <n>] [--ip-address <ip>]
vash server assign-label <hostname> --label <label>
vash server unassign-label <hostname> --label <label>
```

## server-label

```sh
vash server-label list
vash server-label create --name <n> [--color <hex>]
vash server-label edit <name> --new-name <n> [--color <hex>]
vash server-label delete <name>
```

## infrastructure

```sh
vash infrastructure list-os      # list OS images — use ID with server install-vps --os
vash infrastructure list-ips     # list available IP addresses
```
