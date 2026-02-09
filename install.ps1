# Claude Code - StarCraft II Sound Hooks Installer
# Copies sounds and configures Claude Code hooks with SC2 quotes

$ErrorActionPreference = "Stop"

$claudeDir = "$env:USERPROFILE\.claude"
$soundsDir = "$claudeDir\sounds"
$settingsFile = "$claudeDir\settings.json"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Create sounds directory
if (-not (Test-Path $soundsDir)) {
    New-Item -ItemType Directory -Path $soundsDir -Force | Out-Null
}

# Copy all mp3 files and scripts
Write-Host "Copying SC2 sound files..." -ForegroundColor Cyan
Copy-Item "$scriptDir\*.mp3" -Destination $soundsDir -Force
Copy-Item "$scriptDir\play.ps1" -Destination $soundsDir -Force
Copy-Item "$scriptDir\play-random.ps1" -Destination $soundsDir -Force

$s = $soundsDir -replace '\\', '/'

# Build settings JSON
$settings = @"
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -ExecutionPolicy Bypass -File \"$s/play-random.ps1\" \"$s/scv-yes03.mp3\",\"$s/scv-yes05.mp3\",\"$s/scv-what03.mp3\"",
            "async": true
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -ExecutionPolicy Bypass -File \"$s/play.ps1\" \"$s/immortal-what01.mp3\"",
            "async": true
          }
        ]
      }
    ],
    "PermissionRequest": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -ExecutionPolicy Bypass -File \"$s/play-random.ps1\" \"$s/zealot-what01.mp3\",\"$s/zealot-what00.mp3\",\"$s/marauder-say-the-word.mp3\"",
            "async": true
          }
        ]
      }
    ],
    "PostToolUseFailure": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -ExecutionPolicy Bypass -File \"$s/play-random.ps1\" \"$s/additional-pylons.mp3\",\"$s/vespene-gas.mp3\"",
            "async": true
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -ExecutionPolicy Bypass -File \"$s/play-random.ps1\" \"$s/adjutant-research-complete.mp3\",\"$s/adjutant-upgrade-complete.mp3\",\"$s/abathur-evolution-complete.mp3\"",
            "async": true
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -ExecutionPolicy Bypass -File \"$s/play-random.ps1\" \"$s/hightemplar-what00.mp3\",\"$s/siegetank-speak-up.mp3\",\"$s/darktemplar-what-would-you-ask.mp3\"",
            "async": true
          }
        ]
      }
    ]
  }
}
"@

# Check for existing settings
if (Test-Path $settingsFile) {
    Write-Host ""
    Write-Host "WARNING: Existing settings.json found at $settingsFile" -ForegroundColor Yellow
    Write-Host "This will OVERWRITE your current hooks configuration." -ForegroundColor Yellow
    $confirm = Read-Host "Continue? (y/N)"
    if ($confirm -ne 'y' -and $confirm -ne 'Y') {
        Write-Host "Aborted. Sound files were still copied to $soundsDir" -ForegroundColor Yellow
        exit 0
    }
}

$settings | Set-Content -Path $settingsFile -Encoding UTF8
Write-Host ""
Write-Host "SC2 hooks installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Hook assignments:" -ForegroundColor Cyan
Write-Host "  UserPromptSubmit   -> SCV: butter my biscuit / you're the boss / by your will"
Write-Host "  SessionStart       -> Immortal: I feel your presence"
Write-Host "  PermissionRequest  -> Zealot/Marauder: I await your command / your thoughts / say the word"
Write-Host "  PostToolUseFailure -> Additional pylons / vespene gas"
Write-Host "  Stop               -> Adjutant: research complete / upgrade complete / Abathur: evolution complete"
Write-Host "  Notification       -> HT/Tank/DT: my charge / speak up / what would you ask"
Write-Host ""
Write-Host "Missing files you need to add manually:" -ForegroundColor Yellow
Write-Host "  scv-yes03.mp3          (Well butter my biscuit)"
Write-Host "  scv-what03.mp3         (By your will)"
Write-Host "  zealot-what01.mp3      (I await your command)"
Write-Host "  adjutant-upgrade-complete.mp3    (Duty is its own reward)"
Write-Host "  abathur-evolution-complete.mp3 (Evolution complete)"
Write-Host ""
Write-Host "My life for Aiur!" -ForegroundColor Blue
