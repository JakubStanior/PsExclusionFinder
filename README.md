# PsExclusionFinder.ps1

## Overview
`PsExclusionFinder.ps1` is a PowerShell script designed to scan directories and identify folders that are excluded from scanning by Windows Defender as low privileged user. The script leverages `MpCmdRun.exe` to perform the scans and logs the results.

Script is just port of [this .NET Framework tool](https://github.com/Friends-Security/SharpExclusionFinder "this .NET Framework tool"), based on [this research](https://blog.fndsec.net/2024/10/04/uncovering-exclusion-paths-in-microsoft-defender-a-security-research-insight "this research").

## Running

### Get-ExcludedDirectories
This function scans directories to identify folders excluded from Windows Defender scans.

#### Parameters
- **Directory (Mandatory)**: The root directory to start scanning from.
- **Depth (Optional)**: The depth of subdirectories to scan. Default is 1.
- **MpPath (Optional)**: The path to `MpCmdRun.exe`. Default is `"C:\Program Files\Windows Defender\MpCmdRun.exe"`.
- **LogFile (Optional)**: The path to a log file where results will be written.
- **DisablePopUp (Optional)**: A switch to disable Windows Defender popup notifications.

### Disabling Popup Notifications
To determine if folder is excluded we run custom scan on various folders, and windows defender checks for exclusions before scanning. If folder is excluded, console shows *Folder has been skipped*, and visual notification is popped up.
Switch `-DisablePopup`, uses registry key `HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.Defender.SecurityCenter" /v "Enabled"` to disable popups on GUI that folder has been skipped during scanning. Registry key is added on start scanning and is being cleared in the end.

#### Usage
**Example**  
First import module into current session.
`Import-Module .\PsExclusionFinder.ps1`

This example scans the `C:\Users\Example\Documents` directory and its subdirectories up to a depth of 3:

`Get-ExcludedDirectories -Directory "C:\Users\Example\Documents" -Depth 3`

This example scans the `C:\Users\` directory and its subdirectories up to a depth of 4, saves logfile to exclusions_log.txt and disables popup:

`Get-ExcludedDirectories -Directory "C:\Users\" -Depth 4 -LogFile exclusions_log.txt -DisablePopUp`

## Output
- **Console Output**: Displays the progress and results of the scan.
- **Log File**: If a log file path is provided, results are also written to the log file.

Sample output:

    PS C:\Users\Jakub\Desktop\PowerExclusions> Get-ExcludedDirectories -Directory "C:\Users\Jakub\Desktop\PowerExclusions" -Depth 2 -LogFile output.txt
    Found a total of 30 folders inside C:\Users\Jakub\Desktop\PowerExclusions within a depth of 2.
    [+] Folder excluded: C:\Users\Jakub\Desktop\PowerExclusions\Test4\Test44
    [+] Folder excluded: C:\Users\Jakub\Desktop\PowerExclusions\Test5
    [+] Folder excluded: C:\Users\Jakub\Desktop\PowerExclusions\Test5\Test51
    [+] Folder excluded: C:\Users\Jakub\Desktop\PowerExclusions\Test5\Test52
    [+] Folder excluded: C:\Users\Jakub\Desktop\PowerExclusions\Test5\Test53
    [+] Folder excluded: C:\Users\Jakub\Desktop\PowerExclusions\Test5\Test54
    [+] Folder excluded: C:\Users\Jakub\Desktop\PowerExclusions\Test5\Test55
    30 folders completed in 0.6550982 seconds.

## Requirements
- PowerShell
- Windows Defender (`MpCmdRun.exe`)
