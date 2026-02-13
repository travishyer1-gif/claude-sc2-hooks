param([string]$file)
Add-Type -AssemblyName presentationCore
$player = New-Object System.Windows.Media.MediaPlayer
$player.Open([uri]"$file")
Start-Sleep -Milliseconds 500
$player.Play()
$duration = $player.NaturalDuration.TimeSpan.TotalMilliseconds
if ($duration -gt 0) {
    Start-Sleep -Milliseconds ([int]$duration + 200)
} else {
    Start-Sleep -Milliseconds 5000
}
$player.Close()
