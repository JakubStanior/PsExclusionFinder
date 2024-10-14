function Get-ExcludedDirectories {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Directory,

        [Parameter(Mandatory=$false)]
        [int]$Depth = 1, # Default depth 1 if not provided

        [Parameter(Mandatory=$false)]
        [string]$MpPath = "C:\Program Files\Windows Defender\MpCmdRun.exe", # Default path

        [Parameter(Mandatory=$false)]
        [string]$LogFile, # Log file path, not mandatory

        [Parameter(Mandatory=$false)]
        [switch]$DisablePopUp
    )

    function Write-Log {
        param (
            [string]$Message
        )
        
        Write-Host $Message
        if ($LogFile) {
            Add-Content -Path $LogFile -Value $Message
        }
    }

    # Check if MpCmdRun.exe exists and can be executed
    if (-Not (Test-Path -Path $MpPath -PathType Leaf)) {
        Write-Host "Error: MpCmdRun.exe not found at path '$MpPath'."
        return
    }
    
    # Check if the specified directory exists
    if (-Not (Test-Path -Path $Directory -PathType Container)) {
        Write-Host "Error: Directory '$Directory' not found."
        return
    }

    # Set reg key to disable popup
    if($DisablePopup) {
        Write-Host "Disabling Windows Defender popup notifications..."
        Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.Defender.SecurityCenter" /v "Enabled" /t REG_DWORD /d "0" /f
    }
    
    # List all folders inside the specified directory up to the specified depth
    $folders = Get-ChildItem -Path $Directory -Recurse -Directory -Depth ($Depth - 1) -ErrorAction SilentlyContinue | Sort-Object FullName
    Write-Log "Found a total of $($folders.Count) folders inside $Directory within a depth of $Depth."

    if ($folders.Count -eq 0) {
        Write-Host "No folders found."
        return
    }

    $totalFolders = $folders.Count
    $processedFolders = 0
    
    $timer = [System.Diagnostics.Stopwatch]::StartNew()

    foreach ($folder in $folders) {
        # Scan the folder
        $folderPath = $folder.FullName
        $output = & $MpPath -Scan -ScanType 3 -File "$folderPath\|*" 2>&1
        
        if ($output -match "was skipped") {
            Write-Log "[+] Folder excluded: $folderPath"
        }

        # Update progress
        $processedFolders++
        Write-Host -NoNewline "Finished $processedFolders/$totalFolders folders`r"
    }

    $timer.Stop()

    if($DisablePopup) {
        Write-Host "Enabling back Windows Defender popup notifications..."
        Reg.exe delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.Defender.SecurityCenter" /v "Enabled" /f
    }

    Write-Log "$totalFolders folders completed in $($timer.Elapsed.TotalSeconds) seconds."
}
