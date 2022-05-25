# PPKG Scripts for Automated computer setup and prep
**Scripts to use with PPKG package to automate computer setup process**

A collection of scripts that can be ran from a PPKG file to install applications and system updates

```
Commands: (All Commands use ContinueInstall True and RestartRequired False)

	- Set-HighPowerScheme
	CommandFile: C:\Temp\PPKG\Set-PowerHighPerformance.ps1 
	CommandLine: PowerShell.exe -ExecutionPolicy Bypass -File Set-PowerHighPerformance.ps1
	
	- Remove-WindowsJunk
	CommandFile: C:\Temp\PPKG\Remove-WindowsJunk.ps1 
	CommandLine: PowerShell.exe -ExecutionPolicy Bypass -File Remove-WindowsJunk.ps1
		
	- Get-DattoRMM
	CommandFile: C:\Temp\PPKG\XYZTestCompany.exe 
	CommandLine: cmd /c "XYZTestCompany.exe"
	
	- Get-ChocoApps
	CommandFile: C:\Temp\PPKG\Get-ChocoApps.ps1
	CommandLine: PowerShell.exe -ExecutionPolicy Bypass -File Get-ChocoApps.ps1
	
	- Get-SystemUpdates
	CommandFile: C:\Temp\PPKG\Get-SystemUpdates.ps1 
	CommandLine: PowerShell.exe -ExecutionPolicy Bypass -File Get-SystemUpdates.ps1
```
**Setup:**
