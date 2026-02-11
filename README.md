# 🎮 StarCraft II Sound Hooks for Claude Code

Immersive SC2 sound effects for Claude Code events. Every agent interaction gets an iconic StarCraft quote.

**Production-ready** • **Cross-platform** • **Zero config** • **One-line install**

---

## 🚀 Quick Install

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/travishyer1-gif/claude-sc2-hooks/master/install.sh | bash
```

Restart Claude Code and you're done.

### Manual Install

1. Clone this repo to `~/.config/claude/plugins/sc2-hooks`
2. Add to `~/.config/claude/settings.json`:
   ```json
   {
     "plugins": [
       "/Users/yourname/.config/claude/plugins/sc2-hooks/plugin.js"
     ]
   }
   ```
3. Install ffmpeg (for sound playback):
   - **macOS:** `brew install ffmpeg`
   - **Linux:** `sudo apt-get install ffmpeg`

---

## 🎵 Sound Events

| Event | Sound | Quote | Vibe |
|-------|-------|-------|------|
| **User message sent** | SCV | "You're the boss!" / "Well butter my biscuit" / "By your will" | Roger that, working on it |
| **Session starts** | Immortal | "I feel your presence" | I'm online, ready to serve |
| **Agent finishes** | Adjutant | "Research complete" / "Upgrade complete" | Task complete |
| **Permission needed** | Zealot / Marauder | "I await your command" / "Say the word, baby" | Awaiting orders |
| **Tool fails** | Protoss Advisor | "You must construct additional pylons!" / "You require more vespene gas" | Something broke |

---

## 🎨 Customization

All sounds are defined in `sounds/pool.json`. Add your own MP3s and edit the config:

```json
{
  "userPrompt": [
    {
      "file": "scv-yes05.mp3",
      "quote": "You're the boss!",
      "unit": "SCV"
    }
  ],
  "toolFailure": [
    {
      "file": "additional-pylons.mp3",
      "quote": "You must construct additional pylons!",
      "unit": "Protoss Advisor"
    }
  ]
}
```

### Event Types

- `userPrompt` — User submits a message
- `sessionStart` — New session created
- `sessionIdle` — Agent finishes responding (main sessions only)
- `permissionAsked` — Agent needs permission to proceed
- `toolFailure` — Tool execution failed

---

## 🔧 How It Works

1. **Plugin architecture** — Exports a proper Claude Code plugin
2. **State management** — Persists sound assignments per session
3. **Rotation** — Cycles through sound variants for variety
4. **Smart filtering** — Only notifies main sessions (not background subagents)
5. **Session lifecycle** — Cleans up state when sessions end
6. **Zero dependencies** — Just Node.js + ffmpeg

---

## 📂 File Structure

```
claude-sc2-hooks/
├── plugin.js              # Main plugin (Node.js)
├── sounds/
│   ├── pool.json          # Sound configuration
│   └── *.mp3              # SC2 sound files
├── install.sh             # One-line installer
└── README.md              # You are here
```

---

## 🎯 Included Sounds

### Protoss
- **Immortal:** "I feel your presence"
- **High Templar:** "My charge?"
- **Dark Templar:** "What would you ask of us?"
- **Zealot:** "I await your command" / "Your thoughts?"
- **Protoss Advisor:** "You must construct additional pylons!" / "You require more vespene gas"

### Terran
- **SCV:** "You're the boss!" / "Well butter my biscuit" / "By your will"
- **Adjutant:** "Research complete" / "Upgrade complete"
- **Marauder:** "Say the word, baby"
- **Siege Tank:** "Speak up"

---

## 🗑️ Uninstall

```bash
rm -rf ~/.config/claude/plugins/sc2-hooks
```

Then remove the plugin entry from `~/.config/claude/settings.json`.

---

## 🤝 Contributing

Want to add Zerg sounds? More Terran quotes? Submit a PR!

1. Add MP3 files to `sounds/`
2. Update `sounds/pool.json`
3. Test with `node plugin.js` (requires Claude Code running)
4. Submit PR

---

## 📜 License

MIT — Use freely, modify as you like.

---

## 🎮 Credits

- Sound files extracted from StarCraft II
- Inspired by Blizzard's iconic sound design
- Built for the Claude Code community

---

**My life for Aiur!** 🗡️

*En Taro Adun, developers.*
