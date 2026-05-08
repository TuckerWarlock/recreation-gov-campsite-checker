#!/usr/bin/env bash
# Check campsite availability for Yosemite National Park on recreation.gov.
# Usage: ./check.sh --start-date YYYY-MM-DD --end-date YYYY-MM-DD
#
# Override the default parks with --parks <id> [<id> ...] if needed.
# If terminal-notifier is installed (brew install terminal-notifier), a macOS
# notification is sent whenever campsites are found.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ ! -d "$SCRIPT_DIR/venv" ]; then
    echo "Virtual environment not found. Run ./setup.sh first."
    exit 1
fi

source "$SCRIPT_DIR/venv/bin/activate"

# Default to all Yosemite campgrounds unless --parks or --stdin is provided.
if [[ ! " $* " =~ "--parks" ]] && [[ ! " $* " =~ "--stdin" ]]; then
    set -- "$@" --parks \
        232449 232447 232450 232451 10083567 232453 10083845 \
        232452 232448 10004152 232446 10083840 10083831 10220609 10346420
fi

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
