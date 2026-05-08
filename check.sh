#!/usr/bin/env bash
# Check campsite availability on recreation.gov.
# Usage: ./check.sh --start-date YYYY-MM-DD --end-date YYYY-MM-DD --parks <id> [<id> ...]
# All arguments are passed directly to camping.py — see README for full options.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ ! -d "$SCRIPT_DIR/venv" ]; then
    echo "Virtual environment not found. Run ./setup.sh first."
    exit 1
fi

source "$SCRIPT_DIR/venv/bin/activate"
python "$SCRIPT_DIR/camping.py" "$@"
