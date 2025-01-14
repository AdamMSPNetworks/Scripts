$paths = @(
    "C:\INFINITY",
    "C:\ImproMed",
    "C:\TripleCrown",
    "C:\Covetrus",
    "C:\Covetrus, Inc",
    "C:\Henry Schein Veterinary Solutions",
    "C:\Program Files\Microsoft SQL Server",
    "C:\Program Files (x86)\EverSafeG3",
    "C:\Program Files (x86)\ImproMed Desktop Messenger",
    "C:\Program Files (x86)\ImproMed Database Manager",
    "C:\Program Files (x86)\ImproMed, LLC",
    "C:\Program Files (x86)\ImproMedWLS",
    "C:\Program Files (x86)\Infinity",
    "C:\Program Files (x86)\Microsoft SQL Server",
    "C:\Program Files (x86)\ImproMed App Client",
    "C:\Program Files (x86)\Intelligent Inventory Gateway Service",
    "C:\Program Files (x86)\ImproMed Smart Device",
    "C:\Program Files (x86)\ImproMed\ImproMed Universal Lab Reader",
    "C:\Program Files (x86)\Henry Schein Veterinary Solutions",
    "C:\ImproMed\iDocs",
    "C:\Program Files (x86)\Henry Schein",
    "C:\ProgramData\Covetrus, Inc",
    "C:\ProgramData\Henry Schein Veterinary Solutions, LLC",
    "C:\ProgramData\ImproMed",
    "C:\Program Files (x86)\Henry Schein Veterinary Solutions",
    "C:\Program Files (x86)\INFINITY",
    "C:\Program Files (x86)\Infinity",
    "C:\Program Files (x86)\ImproMed",
    "C:\Program Files (x86)\Impromed",
    "C:\Program Files (x86)\TripleCrown",
    "C:\Program Files (x86)\Infinity\Intelligent Inventory Gateway Service\IIGatewaySvc.exe",
    "C:\Program Files (x86)\ImproMed Desktop Messenger\InfinityDesktopMessengerService.exe",
    "C:\Program Files (x86)\ImproMed\ImproMed Database Manager",
    "C:\Program Files (x86)\ImproMed\ImproMed App Client",
    "C:\ProgramData\ImproMed\ImproMed App Client",
    "C:\Program Files (x86)\ImproMed, LLC\ImproMed VetLogic Service Client\VetLogic.Service.exe",
    "C:\Program Files\Microsoft SQL Server\MSSQL11.INFINITY\MSSQL\Binn\sqlservr.exe",
    "C:\Program Files (x86)\ImproMedWLS\ImproMedWLS.exe",
    "C:\Program Files\Microsoft SQL Server\MSSQL11.INFINITY\MSSQL\Binn\SQLAGENT.EXE",
    "C:\Program Files (x86)\Microsoft SQL Server\90\Shared\sqlbrowser.exe"
)

foreach ($path in $paths) {
    if (Test-Path $path) {
        # Allow TCP connections
        New-NetFirewallRule -DisplayName "Allow TCP for $path" -Direction Inbound -Protocol TCP -Action Allow -Program $path -Profile Any
        # Allow UDP connections
        New-NetFirewallRule -DisplayName "Allow UDP for $path" -Direction Inbound -Protocol UDP -Action Allow -Program $path -Profile Any
    } else {
        Write-Host "Path not found: $path"
    }
}
