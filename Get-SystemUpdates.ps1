<#
TITLE: Get-SystemUpdates
PURPOSE: Used with PPKG file to force device to update all Dell drivers and software and then runs Windows updates
CREATOR: Dan Meddock
CREATED: 01APR2022
LAST UPDATED: 24FEB2023
#>

# Log System Updates output to log file
Start-Transcript -Path "C:\temp\PPKG-SystemUpdates.log"

# Declarations

# Uncomment this line if you are running this script manually through powershell
#Set-Executionpolicy -Scope CurrentUser -ExecutionPolicy UnRestricted -Confirm:$False -Force
Set-ExecutionPolicy Bypass -Scope Process -Force

Try{
	# Set TLS settings
	[Net.ServicePointManager]::SecurityProtocol = [Enum]::ToObject([Net.SecurityProtocolType], 3072)
}Catch [system.exception] {
	write-host "- ERROR: Could not implement TLS 1.2 Support."
	write-host "  This can occur on Windows 7 devices lacking Service Pack 1."
	write-host "  Please install that before proceeding."
	exit 1
}

# Check that device is online
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

# Function to run and install Dell Command updates
Function updateDell {
	# Locate dcu-cli.exe and start the Dell Command and Update process
	Try{
		# Download direcotry and DCU-CLI variables
		$logFile = "C:\temp\dellUpdate.log"
		$druLocation64 = "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"
		$druLocation32 = "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"
		
		# Find dcu-cli.exe programfile location
		if (test-path -path $druLocation32 -pathtype leaf){$druDir = $druLocation32}else{$druDir = $druLocation64}	
		
		# Start Dell Command update process; apply all updates and ignore reboot; suspend bitlocker if detected and output log to C:\temp
		write-host "Running Dell Command and Update to update dell drivers."
		start-process -NoNewWindow $druDir -ArgumentList "/applyUpdates -silent -reboot=disable -autoSuspendBitLocker=enable -outputLog=$logFile" -Wait
		get-content $logFile
	}Catch{
		# Catch any powershell errors and output the error message
		write-host $_.Exception.Message
	}
}

# Function to check for all available Windows updates and instal them
Function updateWindows {
	
	Try{
		# Check if PowerCLI is installed; if not then install it
		If(!(Get-InstalledModule PSWindowsUpdate -ErrorAction silentlycontinue)){
			Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Confirm:$False -Force
			Set-PSRepository PSGallery -InstallationPolicy Trusted
			Install-Module PSWindowsUpdate -Confirm:$False -Force
		}
		# Download and log file direcotry and update variables
		$DownloadDir = "C:\temp"
		$logFile ="$DownloadDir\PSWindowsUpdate.log"
		$updatetimeout = 0
		$updates = Get-wulist -verbose
		$updatenumber = ($updates.kb).count
		
		# Check if folders exis
		if (!(Test-Path $DownloadDir)){New-Item -ItemType Directory -Path $DownloadDir}

		#if there are available updates proceed with installing the updates and then reboot the remote machine
		if ($updates -ne $null){			
			# Install windows updates, creates a scheduled task on computer -AutoReboot
			$script = ipmo PSWindowsUpdate; Install-WindowsUpdate -AcceptAll -IgnoreReboot | Out-File $logFile
			Invoke-WUjob -ComputerName localhost -Script $script -Confirm:$false -RunNow -Verbose
			 
			#Show update status until the amount of installed updates equals the same as the amount of updates available
			sleep -Seconds 30
			
			# Monitor update log until all updates have been installed
			do {$updatestatus = Get-Content $DownloadDir\PSWindowsUpdate.log
				Get-Content $DownloadDir\PSWindowsUpdate.log| select-object -last 1
				sleep -Seconds 10
				$ErrorActionPreference = 'SilentlyContinue'
				$installednumber = ([regex]::Matches($updatestatus, "Installed" )).count
				$Failednumber = ([regex]::Matches($updatestatus, "Failed" )).count
				$ErrorActionPreference = 'Continue'
				$updatetimeout++
				echo $installednumber
				echo $Failednumber
				
			# End loop once all updates complete or timeout limit is hit
			}until( ($installednumber + $Failednumber) -ge $updatenumber -or $updatetimeout -ge 60)

			#removes schedule task from computer
			Unregister-ScheduledTask -TaskName PSWindowsUpdate -Confirm:$false

			# rename update log
			$date = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
			Rename-Item $DownloadDir\PSWindowsUpdate.log -NewName "WindowsUpdate-$date.log"
		}
	}catch {
		# Catch any powershell errors and output the error message
		Write-Error $_.Exception.Message
	}
}

# Main

# Check that the device is online before starting updates
test-networkConnection

# Check if device is Dell and if so run Dell Command Updates
If ((Get-ComputerInfo).CsManufacturer -match "Dell"){updateDell}

# Run Windows updates
updateWindows

# Stop transcript logging
Stop-Transcript
Exit 0
