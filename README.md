# Claude Code - StarCraft II Protoss Sound Hooks

SC2 Protoss sound effects for Claude Code hooks. Replaces default sounds with iconic Protoss unit quotes.

## Sound Assignments

| Hook | Sounds | Units |
|------|--------|-------|
| **SessionStart** | Random Immortal/High Templar quote | Immortal, High Templar |
| **Stop** | Random Zealot quote | Zealot |
| **Notification** | Random Zealot quote | Zealot |
| **PostToolUseFailure** | "You must construct additional pylons" / "You require more vespene gas" | Protoss Advisor |

## Install (Windows)

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

This copies sound files to `~/.claude/sounds/` and writes hook config to `~/.claude/settings.json`.

**Note:** This overwrites existing hooks in `settings.json`. Back up your settings first if you have custom config.

## Files

- `play.ps1` - Plays a single sound file
- `play-random.ps1` - Picks and plays a random sound from a list
- `install.ps1` - Automated installer
- `*.mp3` - SC2 Protoss sound clips

## Sound Sources

Clips sourced from community soundboards:
- [Nuclear Launch Detected](https://www.nuclearlaunchdetected.com/)
- [MyInstants](https://www.myinstants.com/)
- [SoundBoardGuy](https://soundboardguy.com/)
