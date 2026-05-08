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

# Set up config file.
if [ ! -f "$SCRIPT_DIR/camping.cfg" ]; then
    cp "$SCRIPT_DIR/camping.cfg.example" "$SCRIPT_DIR/camping.cfg"
    echo ""
    echo "📋 Created camping.cfg — open it and:"
    echo "   1. Set your START_DATE and END_DATE"
    echo "   2. Set PARKS (or leave blank for all Yosemite campgrounds)"
    echo "   3. Optionally fill in Gmail + NOTIFY_EMAIL for email/SMS alerts"
else
    echo "✅ camping.cfg already exists (skipping)"
fi

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
echo "  ./check.sh"
echo ""
echo "To run automatically every 5 minutes, add this line to your crontab (run 'crontab -e'):"
echo "  */5 * * * * $SCRIPT_DIR/check.sh >> $SCRIPT_DIR/camping.log 2>&1"
