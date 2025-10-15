#!/usr/bin/env bash
set -e

echo "=== Installing spec-kit fork as specify-dev ==="

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check for python3
if ! command -v python3 &> /dev/null; then
    echo "Error: python3 is required but not found"
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d "$SCRIPT_DIR/.venv-dev" ]; then
    echo "Creating virtual environment..."
    python3 -m venv "$SCRIPT_DIR/.venv-dev"
fi

# Activate virtual environment
echo "Activating virtual environment..."
source "$SCRIPT_DIR/.venv-dev/bin/activate"

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Install the package in editable mode
echo "Installing spec-kit in editable mode..."
pip install -e "$SCRIPT_DIR"

echo ""
echo "✓ Installation complete!"
echo ""
echo "Usage:"
echo "  1. Activate the virtual environment:"
echo "     source .venv-dev/bin/activate"
echo ""
echo "  2. Use the specify-dev command:"
echo "     specify-dev init test-project --ai claude"
echo ""
echo "  3. When done, deactivate:"
echo "     deactivate"
echo ""
echo "Installed commands:"
which specify-dev 2>/dev/null || echo "  specify-dev: not in PATH (activate venv first)"
