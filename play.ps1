param([string]$file)
Add-Type -AssemblyName presentationCore
$player = New-Object System.Windows.Media.MediaPlayer
$player.Open([uri]"$file")
$player.Play()
Start-Sleep -Milliseconds 2000
$player.Close()
