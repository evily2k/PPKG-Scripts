# PPKG Scripts for automated computer setup and prep
**Scripts to use with PPKG setup file to automate computer setup process**

You will need to edit the Set-DeviceSettings script. There is a function called "setTimeZone" with a API token which will need to be changed once you have setup an account with ipinfo.io and generate your own token. I accidentally released a copy with my token included so I have since setup whitelisting so the token will only work from my IP. If you dont want to create an account to get your own token then just comment the line 136 where it says "setTimeZone" and then the script will run without errors. Using the ipinfo token will also mean you have metrics for how many times the PPKG was used because it logs every ping to the site. So not only is that function good to set the timezone but its also a way to get metrics on how often the PPKG file is used.

A collection of scripts that are used with the Windows Configuration Designer to build a PPKG file. The scripts will do the following:

**Script Descriptions:**
```
Set-DeviceSettings - Applies system settings
	- Checks that the device is online and if not skips all online related processes
	- Disabled Windows Privacy experience
	- Applies the high preformance power scheme.
	- Sets the system time using an online ping service to report the IPs location
	- THe ping service also servers as a metrics source which will keep track of how many times the PPKG is used

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

Get-ChocoApp - Install all apps that are listed under the “$applications” variable which currently includes the following:
	- googlechrome
	- adobereader
	- office365business
	- 7zip
	- dellcommandupdate (If system is Dell it will also install.)

Get-SystemUpdates - 
	- Checks if system is Dell and if so it starts the Dell Command and Update process. 
	- Then use PSWindowsUpdate powershell tool to check for WIndows updates, download updates, and install updates. 
```

**Script Commands and configuration:**
```
- Set-DeviceSettings
	CommandFile: C:\PPKG\Set-DeviceSettings.ps1 
	CommandLine: PowerShell.exe -ExecutionPolicy Bypass -File Set-DeviceSettings.ps1
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

Has not been tested on Windows 11 devices.

Windows 11 device failed to remove the following:
Adobe Express, Spotify, Disney +, Clipchamp Video Editor, Prime Video, Tik Tok, Instagram, and Facebook Messenger are installed
