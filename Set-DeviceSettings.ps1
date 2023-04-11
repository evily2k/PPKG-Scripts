<#
TITLE: Set-DeviceSettings
PURPOSE: This script test network connection, disabled Privacy Experience, sets the power scheme to high preformance
CREATOR: Dan Meddock
CREATED: 25JAN2023
LAST UPDATED: 28MAR2023
#>

# Log Set-DeviceSettings output to log file
Start-Transcript -Path "C:\temp\PPKG-SetDeviceSettings.log"

# Declarations

# Test the device is connected to the internet
function test-networkConnection {
	# Test if there is internet connection
	$ping = test-connection www.google.com -erroraction silentlycontinue
	if($ping){
		Write-Output "The Device is connected to the internet."	
	}else{
		write-output "Internet is required for this script. Exiting out of script."
		Stop-Transcript
		Exit 0
	}
}

# Apply Privacy Experience settings are disabled
function set-privacyExperience {
	
# Declarations
$workingDir = "C:\temp"
$regFile = "disablePrivacy.reg"
$regPath = $workingDir + "\" + $regFile

# Check if the working directory exists
If(!(test-path $workingDir -PathType Leaf)){new-item $workingDir -ItemType Directory -force}

# Registry file content to disable Privacy Experience variable
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
Sleep 5
Remove-Item $regPath -Force
}
	
# Set the device power scheme
function set-powerScheme {
	
	# Check if the device is a laptop
	$laptop = Get-WmiObject -Class win32_systemenclosure | ? { $_.chassistypes -eq 9 -or $_.chassistypes -eq 10 -or $_.chassistypes -eq 14}
	
	if($laptop){
		
		# Capture the active scheme GUID
		$activeScheme = powercfg.exe /getactivescheme
		$regEx = '(\{){0,1}[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}(\}){0,1}'
		$asGuid = [regex]::Match($activeScheme,$regEx).Value
		
		# Relative GUIDs for Lid Close settings
		$pwrGuid = '4f971e89-eebd-4455-a8de-9e59040e7347'
		$lidClosedGuid = '5ca83367-6e45-459f-a27b-476b1d01c936'
		
		# DC Value // On Battery // 1 = sleep
		powercfg.exe /setdcvalueindex $asGuid $pwrGuid $lidClosedGuid 1
		# AC Value // While plugged in // 0 = do nothing
		powercfg.exe /setacvalueindex $asGuid $pwrGuid $lidClosedGuid 0
		
		# Apply settings
		Write-Output "Applying laptop power plan..."
		powercfg.exe /s $asGuid
		powercfg.exe /x -standby-timeout-ac 0
		
	}else{
		# Set High Preformance power scheme
		Write-Output "Applying High Preformance power settings..."
		powercfg.exe /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
	}
}

# Set time zone based off public IP location
function setTimeZone {
	
	# API token for ipinfo.io	
	$apiKey = 'XXXXXXXXXXXXXX'
	$locData = Invoke-RestMethod "https://ipinfo.io?token=$apiKey" -ContentType 'Application/Json'
	
	# Table to match location ID to correct timezone
	$tzList = @{
		#region snippet of the countr / iana code table
		"America/Chicago" = "Central Standard Time"
		"America/New_York" = "Eastern Standard Time"
		"America/Denver"  = "Mountain Standard Time"
		"America/Los_Angeles" = "Pacific Standard Time"
		#endregion
	}
	
	# Match location ID to correct timezone
	$windowsId = $tzList.Get_Item($locData.timezone)
	if ($windowsId) {
		$result = $windowsId
	}else{
		$result = ($tzList.GetEnumerator() | Where-Object { $_.Key -like "*$($locData.timezone)*" }).Value
	}
	
	# Set timezone
	Write-Host "Setting timezone to $result.."
	Set-TimeZone -Id $result
}

# Main

# Apply Privacy Experience settings are disabled
set-privacyExperience

# Set the device power scheme
set-powerScheme

# Test the device is connected to the internet
test-networkConnection

# Set timezone based on IP location data
setTimeZone

Stop-Transcript
Exit 0