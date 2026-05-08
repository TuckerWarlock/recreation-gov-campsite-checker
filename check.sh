#!/usr/bin/env bash
# Check campsite availability on recreation.gov.
# Usage: ./check.sh --start-date YYYY-MM-DD --end-date YYYY-MM-DD --parks <id> [<id> ...]
# All arguments are passed directly to camping.py — see README for full options.
#
# If terminal-notifier is installed (brew install terminal-notifier), a macOS
# notification is sent whenever campsites are found.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ ! -d "$SCRIPT_DIR/venv" ]; then
    echo "Virtual environment not found. Run ./setup.sh first."
    exit 1
fi

source "$SCRIPT_DIR/venv/bin/activate"

output=$(python "$SCRIPT_DIR/camping.py" "$@")
exit_code=$?
echo "$output"

if echo "$output" | grep -q "🏕"; then
    if command -v terminal-notifier &>/dev/null; then
        message=$(echo "$output" | grep "🏕" | head -5 | tr '\n' '  ')
        terminal-notifier \
            -title "🏕 Campsites Available!" \
            -message "$message" \
            -sound default
    fi
fi

exit $exit_code
