param([string[]]$files)
Add-Type -AssemblyName presentationCore
$pick = $files | Get-Random
$player = New-Object System.Windows.Media.MediaPlayer
$player.Open([uri]"$pick")
Start-Sleep -Milliseconds 500
$player.Play()
$duration = $player.NaturalDuration.TimeSpan.TotalMilliseconds
if ($duration -gt 0) {
    Start-Sleep -Milliseconds ([int]$duration + 200)
} else {
    Start-Sleep -Milliseconds 5000
}
$player.Close()
