# PPKG Scripts for automated computer setup and prep
**Scripts to use with PPKG setup file to automate computer setup process**

A collection of scripts that are used with the Windows Configuration Designer to build a PPKG file. The scripts will do the following:

```
Script Descriptions:
	Set-HighPowerScheme - Applies the high preformance power scheme.
	
	Remove-WindowsJunk - Runs the Windows Debloater script and does the following:
		- Removes Blacklisted apps. 
		- Removes leftover bloatware registry keys. 
		- Checks to see if any Whitelisted Apps were removed, and if so re-adding them. 
		- Stops telemetry, disabling unneccessary scheduled tasks, and preventing bloatware from returning. 
		- Checks DWService to prevent SYSPREP from freezing at 'Getting Ready' on first boot.
		- Checks system services are running and setup correctly. 
		- Cleans up startmenu layout and apps. 
		- Removes 3D Objects from the 'My Computer' submenu.
		- Sets Windows to Dark Mode.
		- Disables 'Updates are available' message.
		
	Get-DattoRMM - Installs the specified DattoRMM agent .exe file (Not a script).
	
	Get-ChocoApp - Installs applications that are listed under the “$applications” variable which currently includes the following:
		- googlechrome
		- adobereader
		- office365business
		- 7zip
		- dellcommandupdate (If system is Dell it will also install.)
		
	Get-SystemUpdates - Checks if system is Dell and if so it starts the Dell Command and Update process. 
	Once completed it will then use PSWindowsUpdate powershell tool to check for updates, download updates, and install updates. 
```
```
Commands:

	- Set-HighPowerScheme
	CommandFile: C:\PPKG\Set-PowerHighPerformance.ps1 
	CommandLine: PowerShell.exe -ExecutionPolicy Bypass -File Set-PowerHighPerformance.ps1
	ContinueInstall: True
	RestartRequired: False 
	
	- Remove-WindowsJunk
	CommandFile: C:\PPKG\Remove-WindowsJunk.ps1 
	CommandLine: PowerShell.exe -ExecutionPolicy Bypass -File Remove-WindowsJunk.ps1
	ContinueInstall: True
	RestartRequired: False 
		
	- Get-DattoRMM
	CommandFile: C:\PPKG\XYZTestCompany.exe 
	CommandLine: cmd /c "XYZTestCompany.exe"
	ContinueInstall: True
	RestartRequired: False 
	
	- Get-ChocoApps
	CommandFile: C:\PPKG\Get-ChocoApps.ps1
	CommandLine: PowerShell.exe -ExecutionPolicy Bypass -File Get-ChocoApps.ps1
	ContinueInstall: True
	RestartRequired: False 
	
	- Get-SystemUpdates
	CommandFile: C:\PPKG\Get-SystemUpdates.ps1 
	CommandLine: PowerShell.exe -ExecutionPolicy Bypass -File Get-SystemUpdates.ps1
	ContinueInstall: True
	RestartRequired: True
```
**Note:**
All Script logging is stored in C:\temp. 
