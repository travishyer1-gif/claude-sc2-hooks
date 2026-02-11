#!/bin/bash
set -e

echo "🎮 Installing StarCraft II Sound Hooks for Claude Code..."

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS="linux"
elif [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "mingw"* ]] || [[ "$OSTYPE" == "cygwin"* ]]; then
  OS="windows"
else
  echo "❌ Unsupported OS: $OSTYPE"
  echo "This installer supports macOS, Linux, and Windows (Git Bash)."
  exit 1
fi

# Set platform-specific paths
if [[ "$OS" == "windows" ]]; then
  CLAUDE_DIR="$USERPROFILE/.claude"
else
  CLAUDE_DIR="$HOME/.config/claude"
fi

INSTALL_DIR="$CLAUDE_DIR/plugins/sc2-hooks"
STATE_DIR="$CLAUDE_DIR/sc2-state"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

# Check for ffplay (required for sound playback on macOS/Linux, optional on Windows)
if ! command -v ffplay &> /dev/null; then
  if [[ "$OS" == "macos" ]]; then
    echo "⚠️  ffplay not found. Installing ffmpeg..."
    if command -v brew &> /dev/null; then
      brew install ffmpeg
    else
      echo "❌ Homebrew not found. Please install ffmpeg manually:"
      echo "   https://ffmpeg.org/download.html"
      exit 1
    fi
  elif [[ "$OS" == "linux" ]]; then
    echo "⚠️  ffplay not found. Installing ffmpeg..."
    if command -v apt-get &> /dev/null; then
      sudo apt-get update && sudo apt-get install -y ffmpeg
    elif command -v yum &> /dev/null; then
      sudo yum install -y ffmpeg
    else
      echo "❌ Package manager not found. Please install ffmpeg manually:"
      echo "   https://ffmpeg.org/download.html"
      exit 1
    fi
  elif [[ "$OS" == "windows" ]]; then
    echo "⚠️  ffplay not found. Attempting to install ffmpeg..."
    FFMPEG_INSTALLED=false

    if command -v choco &> /dev/null; then
      echo "   Found Chocolatey, installing ffmpeg..."
      choco install ffmpeg -y && FFMPEG_INSTALLED=true
    elif command -v scoop &> /dev/null; then
      echo "   Found Scoop, installing ffmpeg..."
      scoop install ffmpeg && FFMPEG_INSTALLED=true
    fi

    if [[ "$FFMPEG_INSTALLED" == "false" ]]; then
      echo ""
      echo "ℹ️  Could not install ffmpeg automatically."
      echo "   Install manually: https://ffmpeg.org/download.html"
      echo "   Or run: choco install ffmpeg  /  scoop install ffmpeg"
      echo ""
      echo "   No worries — the plugin will use PowerShell for audio playback instead."
      echo ""
    fi
  fi
fi

# Clone or update repository
if [ -d "$INSTALL_DIR" ]; then
  echo "📦 Updating existing installation..."
  cd "$INSTALL_DIR"
  git pull
else
  echo "📦 Cloning repository..."
  mkdir -p "$(dirname "$INSTALL_DIR")"
  git clone https://github.com/travishyer1-gif/claude-sc2-hooks.git "$INSTALL_DIR"
fi

# Create state directory
mkdir -p "$STATE_DIR"

# Register plugin in Claude Code settings
if [ ! -f "$SETTINGS_FILE" ]; then
  echo "📝 Creating new settings.json..."
  echo '{"plugins":[]}' > "$SETTINGS_FILE"
fi

# Resolve the plugin path
if [[ "$OS" == "windows" ]]; then
  # Convert Windows path to forward slashes for JSON
  PLUGIN_PATH="$(cd "$INSTALL_DIR" && pwd -W 2>/dev/null || pwd)/plugin.js"
  PLUGIN_PATH="${PLUGIN_PATH//\\//}"
else
  PLUGIN_PATH="$INSTALL_DIR/plugin.js"
fi

# Check if plugin already registered
if grep -q "sc2-hooks/plugin.js" "$SETTINGS_FILE" 2>/dev/null; then
  echo "✅ Plugin already registered in settings.json"
else
  echo "📝 Registering plugin in settings.json..."

  # Use Python to safely merge JSON
  PYTHON_CMD="python3"
  if [[ "$OS" == "windows" ]] && ! command -v python3 &> /dev/null; then
    PYTHON_CMD="python"
  fi

  $PYTHON_CMD -c "
import json

settings_path = r'''$SETTINGS_FILE'''
plugin_path = r'''$PLUGIN_PATH'''

with open(settings_path, 'r') as f:
    settings = json.load(f)

if 'plugins' not in settings:
    settings['plugins'] = []

if plugin_path not in settings['plugins']:
    settings['plugins'].append(plugin_path)

with open(settings_path, 'w') as f:
    json.dump(settings, f, indent=2)

print('✅ Plugin registered successfully')
"
fi

echo ""
echo "🎉 Installation complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Restart Claude Code (if running)"
echo "   2. Sounds will play on these events:"
echo "      • User message submitted → SCV acknowledgment"
echo "      • Session starts → Immortal greeting"
echo "      • Agent finishes → Adjutant completion"
echo "      • Permission needed → Zealot/Marauder prompt"
echo "      • Tool fails → Pylons/Vespene error"
echo ""
echo "🎨 Customize sounds:"
echo "   Edit: $INSTALL_DIR/sounds/pool.json"
echo ""
echo "🗑️  Uninstall:"
if [[ "$OS" == "windows" ]]; then
  echo "   rm -rf $INSTALL_DIR"
  echo "   Remove plugin entry from $SETTINGS_FILE"
else
  echo "   rm -rf $INSTALL_DIR"
  echo "   Remove plugin entry from $SETTINGS_FILE"
fi
echo ""
echo "My life for Aiur! 🗡️"
