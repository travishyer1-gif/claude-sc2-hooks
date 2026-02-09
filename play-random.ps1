param([string[]]$files)
Add-Type -AssemblyName presentationCore
$pick = $files | Get-Random
$player = New-Object System.Windows.Media.MediaPlayer
$player.Open([uri]"$pick")
$player.Play()
Start-Sleep -Milliseconds 3000
$player.Close()
