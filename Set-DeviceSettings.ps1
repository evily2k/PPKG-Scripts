<#
TITLE: Set-DeviceSettings
PURPOSE: This script test network connection, disabled Privacy Experience, sets the power scheme to high preformance
CREATOR: Dan Meddock
CREATED: 25JAN2023
LAST UPDATED: 26JAN2023
#>

# Log Windebloater output to log file
Start-Transcript -Path "C:\temp\PPKG-setDeviceSettings.log"

function test-networkConnection {

	# Test if there is internet connection
	$ping = test-connection www.google.com -erroraction silentlycontinue
	if($ping){
		Write-Output "The Device is connected to the internet."	
	}else{
		write-output "No internet detected. Exitting PPKG."
		Stop-Transcript
		Exit 1
	}
}

function set-privacyExperience {
	
# Declarations
$workingDir = "C:\temp"
$regFile = "disablePrivacy.reg"
$regPath = $workingDir + "\" + $regFile

# Check if the working directory exists
If(!(test-path $workingDir -PathType Leaf)){new-item $workingDir -ItemType Directory -force}

# DattoRMM monitor script to uninstall Huntress when Datto is uninstalled
$regSetting = @'
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\OOBE]
"DisablePrivacyExperience"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\OOBE]
"DisablePrivacyExperience"=dword:00000001
'@

# Output scriptblock to directory
$regSetting | out-file $regPath

# Apply registry file using regedit
Write-Output "Disabling Windows Privacy Experience."
Start-Process regedit.exe -argumentlist "/s $regPath"
}
	

function set-powerScheme {

	# Set High Preformance power scheme
	Write-Output "Applying High Preformance power settings..."
	powercfg.exe /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
}

# Test the device is connected to the internet
test-networkConnection

# Apply Privacy Experience settings are disabled
set-privacyExperience

# Set power scheme to high preformance
set-powerScheme

Stop-Transcript
Exit 0