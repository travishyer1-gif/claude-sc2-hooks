# Claude Code - StarCraft II Protoss Sound Hooks Installer
# Copies sounds and configures Claude Code hooks with SC2 Protoss quotes

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
Write-Host "Copying SC2 Protoss sound files..." -ForegroundColor Cyan
Copy-Item "$scriptDir\*.mp3" -Destination $soundsDir -Force
Copy-Item "$scriptDir\play.ps1" -Destination $soundsDir -Force
Copy-Item "$scriptDir\play-random.ps1" -Destination $soundsDir -Force

$soundsPath = $soundsDir -replace '\\', '/'

# Build settings JSON
$settings = @"
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -ExecutionPolicy Bypass -File \"$soundsPath/play-random.ps1\" \"$soundsPath/zealot-yes00.mp3\",\"$soundsPath/zealot-yes01.mp3\",\"$soundsPath/zealot-what00.mp3\",\"$soundsPath/zealot-attack00.mp3\",\"$soundsPath/zealot-attack01.mp3\"",
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
            "command": "powershell -ExecutionPolicy Bypass -File \"$soundsPath/play-random.ps1\" \"$soundsPath/zealot-yes00.mp3\",\"$soundsPath/zealot-yes01.mp3\",\"$soundsPath/zealot-attack00.mp3\"",
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
            "command": "powershell -ExecutionPolicy Bypass -File \"$soundsPath/play-random.ps1\" \"$soundsPath/additional-pylons.mp3\",\"$soundsPath/vespene-gas.mp3\",\"$soundsPath/protoss-needmorefood.mp3\",\"$soundsPath/protoss-needmoregas.mp3\"",
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
            "command": "powershell -ExecutionPolicy Bypass -File \"$soundsPath/play-random.ps1\" \"$soundsPath/immortal-what01.mp3\",\"$soundsPath/immortal-what02.mp3\",\"$soundsPath/immortal-attack00.mp3\",\"$soundsPath/immortal-attack01.mp3\",\"$soundsPath/hightemplar-what00.mp3\",\"$soundsPath/hightemplar-what01.mp3\"",
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
Write-Host "SC2 Protoss hooks installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Hook assignments:" -ForegroundColor Cyan
Write-Host "  SessionStart      -> Immortal & High Templar quotes (random)"
Write-Host "  Stop              -> Zealot quotes (random)"
Write-Host "  Notification      -> Zealot quotes (random)"
Write-Host "  PostToolUseFailure -> 'Additional pylons' / 'Vespene gas' (random)"
Write-Host ""
Write-Host "En taro Tassadar!" -ForegroundColor Blue
