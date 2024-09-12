# Function to get formatted output
function Format-Output {
    param ($Title, $Data)
    Write-Output "`n=== $Title ===`n$Data`n"
}

# System Information
$systemInfo = Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer, CsManufacturer, CsModel, CsProcessors, CsNumberOfLogicalProcessors, CsNumberOfProcessors, CsTotalPhysicalMemory
Format-Output "System Information" ($systemInfo | Format-List | Out-String)

# Disk Information
$diskInfo = Get-Disk | Select-Object Number, FriendlyName, MediaType, OperationalStatus, HealthStatus, Size, PartitionStyle
Format-Output "Disk Information" ($diskInfo | Format-Table -AutoSize | Out-String)

# Network Information
$networkInfo = Get-NetAdapter | Where-Object Status -eq "Up" | Select-Object Name, InterfaceDescription, MacAddress, LinkSpeed
$ipConfig = Get-NetIPConfiguration | Select-Object InterfaceAlias, IPv4Address, IPv6Address
Format-Output "Network Information" (($networkInfo | Format-Table -AutoSize | Out-String) + ($ipConfig | Format-Table -AutoSize | Out-String))

# Installed Software
$installedSoftware = Get-WmiObject -Class Win32_Product | Select-Object Name, Version, Vendor | Sort-Object Name
Format-Output "Installed Software (Top 20)" ($installedSoftware | Select-Object -First 20 | Format-Table -AutoSize | Out-String)

# Running Processes
$processes = Get-Process | Sort-Object CPU -Descending | Select-Object ProcessName, Id, CPU, WorkingSet, StartTime -First 20
Format-Output "Top 20 Running Processes by CPU Usage" ($processes | Format-Table -AutoSize | Out-String)

# Services Status
$services = Get-Service | Where-Object {$_.Status -eq "Running"} | Select-Object Name, DisplayName, Status -First 20
Format-Output "Top 20 Running Services" ($services | Format-Table -AutoSize | Out-String)

# Windows Updates
if (Get-Module -ListAvailable -Name PSWindowsUpdate) {
    Import-Module PSWindowsUpdate
    $updates = Get-WindowsUpdate
    Format-Output "Available Windows Updates" ($updates | Format-Table -AutoSize | Out-String)
} else {
    Write-Output "PSWindowsUpdate module not available. Skipping Windows Update check."
}

# System Event Logs (Last 10 Error events)
$eventLogs = Get-EventLog -LogName System -EntryType Error -Newest 10 | Select-Object TimeGenerated, Source, EventID, Message
Format-Output "Recent System Error Logs" ($eventLogs | Format-Table -AutoSize | Out-String)

# CPU Usage
$cpuUsage = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
Format-Output "Current CPU Usage" "$cpuUsage%"

# Memory Usage
$os = Get-Ciminstance Win32_OperatingSystem
$memoryUsage = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize * 100, 2)
Format-Output "Current Memory Usage" "$memoryUsage%"

# Disk Space
$diskSpace = Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | 
    Select-Object DeviceID, VolumeName, 
    @{Name="Size(GB)";Expression={[math]::Round($_.Size/1GB,2)}}, 
    @{Name="FreeSpace(GB)";Expression={[math]::Round($_.FreeSpace/1GB,2)}}, 
    @{Name="UsedSpace(%)";Expression={[math]::Round(($_.Size - $_.FreeSpace) / $_.Size * 100,2)}}

Format-Output "Disk Space Usage" ($diskSpace | Format-Table -AutoSize | Out-String)
