#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Checking Python version..."
if ! command -v python3 &>/dev/null; then
    echo "❌ Python 3 not found. Install it from https://www.python.org/downloads/ and re-run this script."
    exit 1
fi

if ! python3 -c "import sys; sys.exit(0 if sys.version_info >= (3, 9) else 1)"; then
    FOUND=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    echo "❌ Python 3.9+ is required (found $FOUND). Upgrade at https://www.python.org/downloads/"
    exit 1
fi

echo "✅ Python $(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")"

if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

echo "Installing dependencies..."
source "$SCRIPT_DIR/venv/bin/activate"
pip install --upgrade pip --quiet
pip install -r requirements.txt --quiet

echo ""
if command -v terminal-notifier &>/dev/null; then
    echo "✅ terminal-notifier found — macOS notifications are enabled."
else
    echo "💡 Optional: install terminal-notifier for macOS notifications when sites open up:"
    echo "   brew install terminal-notifier"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Try it out:"
echo "  ./check.sh --start-date 2025-07-01 --end-date 2025-07-07 --parks 232449"
echo ""
echo "To run automatically every 5 minutes, add this line to your crontab (run 'crontab -e'):"
echo "  */5 * * * * $SCRIPT_DIR/check.sh --start-date 2025-07-01 --end-date 2025-07-07 --parks 232449 >> $SCRIPT_DIR/camping.log 2>&1"
