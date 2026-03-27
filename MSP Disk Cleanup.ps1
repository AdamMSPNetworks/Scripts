# MSPNetworks Disk Cleanup

Function Log {
    param(
        [string]$msg,
        [string]$level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "$timestamp [$level] $msg"
}

Function Get-DiskSpaceGB {
    $drive = Get-PSDrive C
    return [math]::Round($drive.Free / 1GB, 2)
}

Write-Host "MSPNetworks Disk Cleanup"
Write-Host ""

Log "Starting Disk Cleanup..."
$spaceBefore = Get-DiskSpaceGB
Log "Disk space free before cleanup: ${spaceBefore} GB"

# Clean Windows Temp
try {
    Log "Cleaning Windows Temp..."
    Get-ChildItem "C:\Windows\Temp" -Recurse -Force -ErrorAction SilentlyContinue |
        Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Log "Windows Temp cleaned." "OK"
} catch { Log "Error cleaning Windows Temp: $_" "ERR" }

# Clean All User Temp Folders
try {
    Log "Cleaning User Temp folders..."
    Get-ChildItem "C:\Users" -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object {
        $path = "$($_.FullName)\AppData\Local\Temp"
        if (Test-Path $path) {
            Log "Cleaning temp for user: $($_.Name)"
            Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue |
                Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } |
                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        }
    }
    Log "User Temp folders cleaned." "OK"
} catch { Log "Error cleaning User Temp folders: $_" "ERR" }

# Clean SoftwareDistribution (Windows Update Cache)
try {
    Log "Cleaning SoftwareDistribution Download cache..."
    Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service wuauserv -ErrorAction SilentlyContinue
    Log "SoftwareDistribution cleaned." "OK"
} catch { Log "Error cleaning SoftwareDistribution: $_" "ERR" }

# Clean Delivery Optimization Cache
try {
    Log "Cleaning Delivery Optimization Cache..."
    if (Get-Command Delete-DeliveryOptimizationCache -ErrorAction SilentlyContinue) {
        Delete-DeliveryOptimizationCache -Force -ErrorAction SilentlyContinue
    } else {
        Stop-Service DoSvc -Force -ErrorAction SilentlyContinue
        Remove-Item "C:\Windows\SoftwareDistribution\DeliveryOptimization\*" -Recurse -Force -ErrorAction SilentlyContinue
        Start-Service DoSvc -ErrorAction SilentlyContinue
    }
    Log "Delivery Optimization Cache cleaned." "OK"
} catch { Log "Error cleaning Delivery Optimization Cache: $_" "ERR" }

# Clean Windows Error Reporting
try {
    Log "Cleaning Windows Error Reporting cache..."
    Remove-Item "C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\ProgramData\Microsoft\Windows\WER\ReportArchive\*" -Recurse -Force -ErrorAction SilentlyContinue
    Log "Windows Error Reporting cache cleaned." "OK"
} catch { Log "Error cleaning WER cache: $_" "ERR" }

# Clean CBS Logs
try {
    Log "Cleaning CBS Logs..."
    Get-ChildItem "C:\Windows\Logs\CBS" -Recurse -Force -ErrorAction SilentlyContinue |
        Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Log "CBS Logs cleaned." "OK"
} catch { Log "Error cleaning CBS Logs: $_" "ERR" }

# Clean Teams Cache (all users)
try {
    Log "Cleaning Microsoft Teams Cache..."
    Get-ChildItem "C:\Users" -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object {
        $path = "$($_.FullName)\AppData\Roaming\Microsoft\Teams\Cache"
        if (Test-Path $path) {
            Log "Cleaning Teams cache for user: $($_.Name)"
            Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue |
                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        }
    }
    Log "Teams Cache cleaned." "OK"
} catch { Log "Error cleaning Teams Cache: $_" "ERR" }

# Clean User CrashDumps (all users)
try {
    Log "Cleaning User CrashDumps..."
    Get-ChildItem "C:\Users" -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object {
        $path = "$($_.FullName)\AppData\Local\CrashDumps"
        if (Test-Path $path) {
            Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue |
                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        }
    }
    Log "User CrashDumps cleaned." "OK"
} catch { Log "Error cleaning CrashDumps: $_" "ERR" }

# Empty Recycle Bin
try {
    Log "Emptying Recycle Bin..."
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Log "Recycle Bin emptied." "OK"
} catch { Log "Error emptying Recycle Bin: $_" "ERR" }

# Clean Prefetch
try {
    Log "Cleaning Prefetch..."
    Remove-Item "C:\Windows\Prefetch\*" -Force -ErrorAction SilentlyContinue
    Log "Prefetch cleaned." "OK"
} catch { Log "Error cleaning Prefetch: $_" "ERR" }

# Remove Memory Dumps
try {
    Log "Removing Memory Dump Files..."
    Remove-Item "C:\Windows\*.dmp" -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\Windows\Minidump\*" -Force -Recurse -ErrorAction SilentlyContinue
    Log "Memory Dump Files removed." "OK"
} catch { Log "Error removing dump files: $_" "ERR" }

# Disable Hibernation and delete hiberfil.sys
try {
    Log "Disabling Hibernation and removing hiberfil.sys..."
    $proc = Start-Process powercfg -ArgumentList "-h off" -WindowStyle Hidden -PassThru -Wait
    if ($proc.ExitCode -eq 0) {
        Log "Hibernation disabled and hiberfil.sys removed." "OK"
    } else {
        Log "Hibernation may already be disabled." "INFO"
    }
} catch { Log "Error disabling hibernation: $_" "ERR" }

# Stop camsvc, remove WAL files, restart
try {
    Log "Cleaning Capability Access Manager WAL files..."
    Stop-Service -Name "camsvc" -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\ProgramData\Microsoft\Windows\CapabilityAccessManager\CapabilityAccessManager.db-wal" -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\ProgramData\Microsoft\Windows\CapabilityAccessManager\CapabilityAccessManager.db-shm" -Force -ErrorAction SilentlyContinue
    Start-Service -Name "camsvc" -ErrorAction SilentlyContinue
    Log "Capability Access Manager WAL files cleaned." "OK"
} catch { Log "Error cleaning Capability Access Manager WAL files: $_" "ERR" }

# Pre-register cleanmgr flags via registry
try {
    Log "Registering cleanmgr flags..."
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
    $categories = @(
        "Update Cleanup",
        "Windows Defender",
        "Downloaded Program Files",
        "D3D Shader Cache",
        "Delivery Optimization Files",
        "Device Driver Packages",
        "LanguagePack",
        "Recycle Bin",
        "Temporary Files",
        "Thumbnail Cache"
    )
    foreach ($category in $categories) {
        $path = "$regPath\$category"
        if (Test-Path $path) {
            Set-ItemProperty -Path $path -Name "StateFlags0001" -Value 2 -Type DWord -ErrorAction SilentlyContinue
        }
    }
    Log "cleanmgr flags registered." "OK"
} catch { Log "Error registering cleanmgr flags: $_" "ERR" }

# Run Windows built-in Disk Cleanup (hidden)
try {
    Log "Running cleanmgr /sagerun:1..."
    $proc = Start-Process cleanmgr -ArgumentList "/sagerun:1" -WindowStyle Hidden -PassThru
    $proc.WaitForExit()
    Log "cleanmgr completed." "OK"
} catch { Log "Error running cleanmgr: $_" "ERR" }

# Final Summary
$spaceAfter = Get-DiskSpaceGB
$recovered = [math]::Round($spaceAfter - $spaceBefore, 2)
Log "Disk space free after cleanup: ${spaceAfter} GB"
Log "Space recovered: ${recovered} GB"
Log "Disk Cleanup Completed." "OK"
