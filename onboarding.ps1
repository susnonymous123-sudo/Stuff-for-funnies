# 1. THE POPUP: Immediate feedback that the script ran
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.MessageBox]::Show("SYSTEM CHECK: Welcome to the Cyber Branch. Find the 'OnboardingChallenge' Registry Key to stop this message from appearing at boot!", "Security Alert")

# 2. THE FLAG: Proof that the script can write to the user's files
$flagPath = "$env:USERPROFILE\Desktop\CHALLENGE_FLAG.txt"
"Timestamp: $(Get-Date) - Initial Access Successful. Status: Managed." | Out-File -FilePath $flagPath

# 3. PERSISTENCE: This is the "Challenge" for your team
# This adds a command to the Windows 'Run' key so it triggers every login
$triggerCommand = "msg * 'The challenge is still active. Dig into Regedit to find the OnboardingChallenge key!'"
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'OnboardingChallenge' -Value $triggerCommand
