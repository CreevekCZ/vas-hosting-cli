#!/usr/bin/env bash
#
# E2E smoke tests for vash CLI — read-only (GET) endpoints only.
# Usage: ./scripts/e2e-test.sh
#

set -uo pipefail

# ── Config ───────────────────────────────────────────────────────────
DOMAINS=("audasty.cz" "audasty.app" "audasty.com")
PASS=0
FAIL=0
XFAIL=0  # expected failures (tariff/permissions)
BUG=0    # decoding bugs
ERRORS=()
BUGS=()

# ── Helpers ──────────────────────────────────────────────────────────
green()  { printf "\033[32m%s\033[0m" "$*"; }
red()    { printf "\033[31m%s\033[0m" "$*"; }
yellow() { printf "\033[33m%s\033[0m" "$*"; }
cyan()   { printf "\033[36m%s\033[0m" "$*"; }
bold()   { printf "\033[1m%s\033[0m\n" "$*"; }

# run_test NAME CMD
# Runs a command, captures stdout+stderr, classifies the result.
run_test() {
    local name="$1"
    shift
    local cmd="$*"

    printf "  %-55s " "$name"
    local output exit_code
    output=$(eval "$cmd" 2>&1)
    exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        green "PASS"; echo ""
        ((PASS++))
        return
    fi

    # Classify failure
    if echo "$output" | grep -q "found an array instead"; then
        cyan "BUG"; echo " (array vs object mismatch)"
        BUGS+=("$name|$cmd|array vs object: API returns [] but spec expects {}")
        ((BUG++))
    elif echo "$output" | grep -q "keyNotFound"; then
        local missing_key
        missing_key=$(echo "$output" | sed -n 's/.*stringValue: "\([^"]*\)".*/\1/p' | head -1)
        cyan "BUG"; echo " (missing key: $missing_key)"
        BUGS+=("$name|$cmd|missing required key: $missing_key")
        ((BUG++))
    elif echo "$output" | grep -q "tariff does not include\|Unauthorized\|unauthorized"; then
        yellow "XFAIL"; echo " (tariff/permission)"
        ((XFAIL++))
    elif echo "$output" | grep -q "Unexpected HTTP status: 403"; then
        yellow "XFAIL"; echo " (HTTP 403)"
        ((XFAIL++))
    elif echo "$output" | grep -q "not found\|404"; then
        yellow "XFAIL"; echo " (not found)"
        ((XFAIL++))
    else
        red "FAIL"; echo " (exit $exit_code)"
        ERRORS+=("$name|$cmd|$output")
        ((FAIL++))
    fi
}

separator() {
    echo ""
    bold "── $1 ──"
}

# ── Preflight ────────────────────────────────────────────────────────
bold "=== vash CLI E2E Tests (read-only) ==="
echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

if ! command -v vash &>/dev/null; then
    red "ERROR: vash not found in PATH"; echo ""
    exit 1
fi
echo "vash path: $(which vash)"

# ── Auth ─────────────────────────────────────────────────────────────
separator "Auth"
run_test "auth current"                     "vash auth current"
run_test "auth list"                        "vash auth list"
run_test "auth list --format json"          "vash auth list --format json"

# ── Servers ──────────────────────────────────────────────────────────
separator "Servers"
run_test "server list"                      "vash server list"
run_test "server list --format json"        "vash server list --format json"
run_test "server list-vds"                  "vash server list-vds"
run_test "server list-vds --format json"    "vash server list-vds --format json"

# Try to discover a hostname for server info
HOSTNAME=$(vash server list --format json 2>/dev/null | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if isinstance(data, dict):
        keys = list(data.keys())
        if keys: print(keys[0])
    elif isinstance(data, list) and data:
        for key in ['hostname', 'name', 'server', 'host']:
            if key in data[0]:
                print(data[0][key]); break
except: pass
" 2>/dev/null || true)

if [[ -n "${HOSTNAME:-}" ]]; then
    echo "  (discovered hostname: $HOSTNAME)"
    run_test "server info $HOSTNAME"                "vash server info '$HOSTNAME'"
    run_test "server info $HOSTNAME --format json"  "vash server info '$HOSTNAME' --format json"
else
    echo "  (no hostname discovered — skipping server info)"
fi

# ── Server Labels ────────────────────────────────────────────────────
separator "Server Labels"
run_test "server-label list"                "vash server-label list"
run_test "server-label list --format json"  "vash server-label list --format json"

# ── Infrastructure ───────────────────────────────────────────────────
separator "Infrastructure"
run_test "infrastructure list-os"                   "vash infrastructure list-os"
run_test "infrastructure list-os --format json"     "vash infrastructure list-os --format json"
run_test "infrastructure list-ips"                  "vash infrastructure list-ips"
run_test "infrastructure list-ips --format json"    "vash infrastructure list-ips --format json"

# ── Account ──────────────────────────────────────────────────────────
separator "Account"
run_test "account invoices"                 "vash account invoices"
run_test "account invoices --format json"   "vash account invoices --format json"

# ── Per-domain tests ─────────────────────────────────────────────────
for domain in "${DOMAINS[@]}"; do
    separator "Domain: $domain"

    run_test "domain info $domain"              "vash domain info '$domain'"
    run_test "domain info $domain --format json" "vash domain info '$domain' --format json"
    run_test "dns list $domain"                 "vash dns list '$domain'"
    run_test "dns list $domain --format json"   "vash dns list '$domain' --format json"
    run_test "database list $domain"            "vash database list '$domain'"
    run_test "database list $domain --format json" "vash database list '$domain' --format json"
    run_test "email list $domain"               "vash email list '$domain'"
    run_test "email list $domain --format json" "vash email list '$domain' --format json"
    run_test "ftp list $domain"                 "vash ftp list '$domain'"
    run_test "ftp list $domain --format json"   "vash ftp list '$domain' --format json"
done

# ── Summary ──────────────────────────────────────────────────────────
echo ""
bold "============================================="
bold "                  SUMMARY"
bold "============================================="
green "  PASS:  $PASS"; echo ""
if [[ $BUG -gt 0 ]]; then
    cyan "  BUG:   $BUG"; echo "  (decoding/schema mismatches)"
fi
if [[ $XFAIL -gt 0 ]]; then
    yellow "  XFAIL: $XFAIL"; echo "  (expected — tariff/permissions)"
fi
if [[ $FAIL -gt 0 ]]; then
    red "  FAIL:  $FAIL"; echo "  (unexpected failures)"
fi
echo "  TOTAL: $((PASS + BUG + XFAIL + FAIL))"

# Print bug details
if [[ ${#BUGS[@]} -gt 0 ]]; then
    echo ""
    bold "============================================="
    bold "              BUGS FOUND"
    bold "============================================="
    for bug in "${BUGS[@]}"; do
        IFS='|' read -r bname bcmd bdetail <<< "$bug"
        echo "  $(cyan "BUG") $bname"
        echo "       cmd: $bcmd"
        echo "       issue: $bdetail"
        echo ""
    done
fi

# Print unexpected failure details
if [[ ${#ERRORS[@]} -gt 0 ]]; then
    echo ""
    bold "============================================="
    bold "          UNEXPECTED FAILURES"
    bold "============================================="
    for err in "${ERRORS[@]}"; do
        IFS='|' read -r ename ecmd eoutput <<< "$err"
        echo "  $(red "FAIL") $ename"
        echo "       cmd: $ecmd"
        echo "       output: $eoutput"
        echo ""
    done
fi

# Exit code: 1 if any real bugs or unexpected failures
if [[ $BUG -gt 0 || $FAIL -gt 0 ]]; then
    exit 1
fi
