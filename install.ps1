# Claude Code - StarCraft II Sound Hooks Installer (Plugin Architecture)
# Clones repo, registers plugin.js, and sets up state directory

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "Installing StarCraft II Sound Hooks for Claude Code..." -ForegroundColor Cyan
Write-Host ""

$claudeDir = "$env:USERPROFILE\.claude"
$installDir = "$claudeDir\plugins\sc2-hooks"
$stateDir = "$claudeDir\sc2-state"
$settingsFile = "$claudeDir\settings.json"
$repoUrl = "https://github.com/travishyer1-gif/claude-sc2-hooks.git"

# Check for ffplay / ffmpeg (optional — PowerShell fallback is built-in)
if (-not (Get-Command ffplay -ErrorAction SilentlyContinue)) {
    Write-Host "ffplay not found. Checking for package managers..." -ForegroundColor Yellow

    $installed = $false

    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "  Found Chocolatey, installing ffmpeg..." -ForegroundColor Cyan
        try {
            choco install ffmpeg -y | Out-Null
            $installed = $true
        } catch {
            Write-Host "  Chocolatey install failed." -ForegroundColor Yellow
        }
    }

    if (-not $installed -and (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "  Found Scoop, installing ffmpeg..." -ForegroundColor Cyan
        try {
            scoop install ffmpeg | Out-Null
            $installed = $true
        } catch {
            Write-Host "  Scoop install failed." -ForegroundColor Yellow
        }
    }

    if (-not $installed -and (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "  Found winget, installing ffmpeg..." -ForegroundColor Cyan
        try {
            winget install --id Gyan.FFmpeg -e --accept-package-agreements --accept-source-agreements | Out-Null
            $installed = $true
        } catch {
            Write-Host "  winget install failed." -ForegroundColor Yellow
        }
    }

    if (-not $installed) {
        Write-Host ""
        Write-Host "  Could not install ffmpeg automatically." -ForegroundColor Yellow
        Write-Host "  Install manually: https://ffmpeg.org/download.html" -ForegroundColor Yellow
        Write-Host "  Or run: choco install ffmpeg / scoop install ffmpeg / winget install Gyan.FFmpeg" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  No worries - the plugin will use PowerShell for audio playback instead." -ForegroundColor Green
        Write-Host ""
    }
} else {
    Write-Host "ffplay found." -ForegroundColor Green
}

# Clone or update repository
if (Test-Path $installDir) {
    Write-Host "Updating existing installation..." -ForegroundColor Cyan
    Push-Location $installDir
    try {
        git pull
    } catch {
        Write-Host "  git pull failed, re-cloning..." -ForegroundColor Yellow
        Pop-Location
        Remove-Item -Recurse -Force $installDir
        git clone $repoUrl $installDir
    }
    if ((Get-Location).Path -eq $installDir) { Pop-Location }
} else {
    Write-Host "Cloning repository..." -ForegroundColor Cyan
    $parentDir = Split-Path $installDir -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }
    git clone $repoUrl $installDir
}

# Create state directory
if (-not (Test-Path $stateDir)) {
    New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
}

# Register plugin in Claude Code settings
$pluginPath = "$installDir\plugin.js" -replace '\\', '/'

if (-not (Test-Path $settingsFile)) {
    Write-Host "Creating new settings.json..." -ForegroundColor Cyan
    @{ plugins = @($pluginPath) } | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsFile -Encoding UTF8
    Write-Host "Plugin registered successfully." -ForegroundColor Green
} else {
    $settings = Get-Content $settingsFile -Raw | ConvertFrom-Json

    # Ensure plugins array exists
    if (-not $settings.plugins) {
        $settings | Add-Member -NotePropertyName "plugins" -NotePropertyValue @() -Force
    }

    # Check if already registered
    $alreadyRegistered = $settings.plugins | Where-Object { $_ -like "*sc2-hooks/plugin.js*" }

    if ($alreadyRegistered) {
        Write-Host "Plugin already registered in settings.json." -ForegroundColor Green
    } else {
        $settings.plugins = @($settings.plugins) + $pluginPath
        $settings | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsFile -Encoding UTF8
        Write-Host "Plugin registered successfully." -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Restart Claude Code (if running)"
Write-Host "  2. Sounds will play on these events:"
Write-Host "     - User message submitted -> SCV acknowledgment"
Write-Host "     - Session starts -> Immortal greeting"
Write-Host "     - Agent finishes -> Adjutant completion"
Write-Host "     - Permission needed -> Zealot/Marauder prompt"
Write-Host "     - Tool fails -> Pylons/Vespene error"
Write-Host ""
Write-Host "Customize sounds:" -ForegroundColor Cyan
Write-Host "  Edit: $installDir\sounds\pool.json"
Write-Host ""
Write-Host "Uninstall:" -ForegroundColor Cyan
Write-Host "  Remove-Item -Recurse -Force `"$installDir`""
Write-Host "  Remove-Item -Recurse -Force `"$stateDir`""
Write-Host "  Remove plugin entry from $settingsFile"
Write-Host ""
Write-Host "My life for Aiur!" -ForegroundColor Blue
