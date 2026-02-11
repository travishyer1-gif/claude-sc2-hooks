#!/bin/bash
set -e

echo "🎮 Installing StarCraft II Sound Hooks for Claude Code..."

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS="linux"
else
  echo "❌ Unsupported OS: $OSTYPE"
  echo "This installer supports macOS and Linux only."
  exit 1
fi

# Check for ffplay (required for sound playback)
if ! command -v ffplay &> /dev/null; then
  echo "⚠️  ffplay not found. Installing ffmpeg..."
  
  if [[ "$OS" == "macos" ]]; then
    if command -v brew &> /dev/null; then
      brew install ffmpeg
    else
      echo "❌ Homebrew not found. Please install ffmpeg manually:"
      echo "   https://ffmpeg.org/download.html"
      exit 1
    fi
  elif [[ "$OS" == "linux" ]]; then
    if command -v apt-get &> /dev/null; then
      sudo apt-get update && sudo apt-get install -y ffmpeg
    elif command -v yum &> /dev/null; then
      sudo yum install -y ffmpeg
    else
      echo "❌ Package manager not found. Please install ffmpeg manually:"
      echo "   https://ffmpeg.org/download.html"
      exit 1
    fi
  fi
fi

# Clone or update repository
INSTALL_DIR="$HOME/.config/claude/plugins/sc2-hooks"

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
mkdir -p "$HOME/.config/claude/sc2-state"

# Register plugin in Claude Code settings
SETTINGS_FILE="$HOME/.config/claude/settings.json"

if [ ! -f "$SETTINGS_FILE" ]; then
  echo "📝 Creating new settings.json..."
  echo '{"plugins":[]}' > "$SETTINGS_FILE"
fi

# Check if plugin already registered
if grep -q "sc2-hooks/plugin.js" "$SETTINGS_FILE" 2>/dev/null; then
  echo "✅ Plugin already registered in settings.json"
else
  echo "📝 Registering plugin in settings.json..."
  
  # Use Python to safely merge JSON (works on both macOS and Linux)
  python3 -c "
import json
import sys

settings_path = '$SETTINGS_FILE'
plugin_path = '$INSTALL_DIR/plugin.js'

with open(settings_path, 'r') as f:
    settings = json.load(f)

if 'plugins' not in settings:
    settings['plugins'] = []

# Check if already exists
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
echo "   rm -rf $INSTALL_DIR"
echo "   Remove plugin entry from $SETTINGS_FILE"
echo ""
echo "My life for Aiur! 🗡️"
