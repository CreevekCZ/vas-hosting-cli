This repository contains `vash`, a CLI for managing vas-hosting.cz hosting services.

For complete command reference see `llms.txt` in the repo root.

## Key facts for code suggestions

- All API commands use `--format table` (default) or `--format json`
- Errors in JSON mode go to stderr as `{"error":"...","code":"..."}`
- Multiple accounts supported; override per-command with `--account <name>`
- Database types: `mysql`, `postgresql`
- DNS types: `A`, `AAAA`, `CNAME`, `MX`, `TXT`, `NS`, `SRV`, `CAA`, `PTR`, `SOA`
