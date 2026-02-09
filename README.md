# Claude Code - StarCraft II Sound Hooks

SC2 sound effects for Claude Code hooks. Terran, Protoss, and Zerg quotes mapped to Claude Code events.

## Hook Assignments

| Hook | Sounds | Vibe |
|------|--------|------|
| **UserPromptSubmit** | SCV: "Well butter my biscuit" / "You're the boss!" / "By your will" | Acknowledged, working on it |
| **SessionStart** | Immortal: "I feel your presence" | I'm online, ready |
| **PermissionRequest** | Zealot: "I await your command" / "Your thoughts?" / Marauder: "Say the word, baby" | Awaiting orders |
| **PostToolUseFailure** | "You must construct additional pylons!" / "You require more vespene gas" | Something broke |
| **Stop** | Adjutant: "Research complete" / "Duty is its own reward" / Abathur: "Evolution complete" | Task complete |
| **Notification** | High Templar: "My charge?" / Siege Tank: "Speak up" / Dark Templar: "What would you ask of us?" | Needs attention |

## Install (Windows)

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

This copies sound files to `~/.claude/sounds/` and writes hook config to `~/.claude/settings.json`.

**Note:** This overwrites existing hooks in `settings.json`. Back up your settings first if you have custom config.

## Sound Files

### Included in repo
| File | Quote | Unit |
|------|-------|------|
| `additional-pylons.mp3` | "You must construct additional pylons!" | Protoss Advisor |
| `adjutant-research-complete.mp3` | "Research complete" | Adjutant |
| `darktemplar-what-would-you-ask.mp3` | "What would you ask of us?" | Dark Templar |
| `hightemplar-what00.mp3` | "My charge?" | High Templar |
| `immortal-what01.mp3` | "I feel your presence" | Immortal |
| `marauder-say-the-word.mp3` | "Say the word, baby" | Marauder |
| `scv-yes05.mp3` | "You're the boss!" | SCV |
| `siegetank-speak-up.mp3` | "Speak up" | Siege Tank |
| `vespene-gas.mp3` | "You require more vespene gas" | Protoss Advisor |
| `zealot-what00.mp3` | "Your thoughts?" | Zealot |

### Need to add manually
| File | Quote | Unit | Source |
|------|-------|------|--------|
| `scv-yes03.mp3` | "Well butter my biscuit" | SCV | Soundboard / game files |
| `scv-what03.mp3` | "By your will" | SCV | Soundboard / game files |
| `zealot-what01.mp3` | "I await your command" | Zealot | Soundboard / game files |
| `scv-duty-reward.mp3` | "Duty is its own reward" | SCV/Zealot | Soundboard / game files |
| `abathur-evolution-complete.mp3` | "Evolution complete" | Abathur | User-provided |

## Files

- `play.ps1` - Plays a single sound file
- `play-random.ps1` - Picks and plays a random sound from a list
- `install.ps1` - Automated installer
- `*.mp3` - SC2 sound clips

## My life for Aiur!
