#!/usr/bin/env bash
# Check campsite availability for Yosemite National Park on recreation.gov.
# Configuration (dates, parks, notifications) is read from camping.cfg.
# Usage: ./check.sh                          # uses camping.cfg
#        ./check.sh --start-date ... --end-date ... [--parks ...]  # overrides config
#
# If terminal-notifier is installed (brew install terminal-notifier), a macOS
# notification is sent whenever campsites are found.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ ! -d "$SCRIPT_DIR/venv" ]; then
    echo "Virtual environment not found. Run ./setup.sh first."
    exit 1
fi

# Load config (sets START_DATE, END_DATE, PARKS, and email vars).
if [ -f "$SCRIPT_DIR/camping.cfg" ]; then
    source "$SCRIPT_DIR/camping.cfg"
fi

# Build args — CLI args take precedence over camping.cfg values.
ARGS=("$@")

if [[ ! " $* " =~ "--start-date" ]] && [ -n "$START_DATE" ]; then
    ARGS+=(--start-date "$START_DATE")
fi

if [[ ! " $* " =~ "--end-date" ]] && [ -n "$END_DATE" ]; then
    ARGS+=(--end-date "$END_DATE")
fi

# Parks: CLI > camping.cfg > default all Yosemite campgrounds.
if [[ ! " $* " =~ "--parks" ]] && [[ ! " $* " =~ "--stdin" ]]; then
    if [ -n "$PARKS" ]; then
        ARGS+=(--parks $PARKS)
    else
        ARGS+=(--parks \
            232449 232447 232450 232451 10083567 232453 10083845 \
            232452 232448 10004152 232446 10083840 10083831 10220609 10346420)
    fi
fi

source "$SCRIPT_DIR/venv/bin/activate"

output=$(python "$SCRIPT_DIR/camping.py" "${ARGS[@]}")
exit_code=$?
echo "$output"

if echo "$output" | grep -q "🏕"; then
    # macOS native notification (optional).
    if command -v terminal-notifier &>/dev/null; then
        message=$(echo "$output" | grep "🏕" | head -5 | tr '\n' '  ')
        terminal-notifier \
            -title "🏕 Campsites Available!" \
            -message "$message" \
            -sound default
    fi

    # Email / SMS notification (optional, configured in camping.cfg).
    echo "$output" | \
        NTFY_TOPIC="$NTFY_TOPIC" \
        EMAIL_ADDRESS="$EMAIL_ADDRESS" \
        EMAIL_PASSWORD="$EMAIL_PASSWORD" \
        NOTIFY_EMAIL="$NOTIFY_EMAIL" \
        python "$SCRIPT_DIR/notify.py"
fi

exit $exit_code
