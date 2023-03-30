<#
TITLE: Get-ChocoApps
PURPOSE: Used with PPKG file to install 3rd party applications
CREATOR: Dan Meddock
CREATED: 28MAR2022
LAST UPDATED: 28MAR2023
#>

# Log Get-ChocoApps output to log file
Start-Transcript -Path "C:\temp\PPKG-ChocoApps.log"

# Declarations

# Enable script execution
Set-ExecutionPolicy Bypass -Scope Process -Force

# Add any Chocolatey supported applications to this list to be installed
$applications = @(
	'googlechrome'
	'adobereader'
	'7zip'
)

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

# Download and install Chocolatey
function InstallUpdateChoco {
    $bool = 0
    Try {
        if (!(Test-Path($env:ChocolateyInstall + "\choco.exe"))) {
			iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
        }
    }Catch{
        Write-Host $($_.Exception.Message)
    }
}

# Installs the application using Chocolatey
function InstallChocoApp {
	Try{
		if ($app -ne " ") {
			$app.Split(" ") | % {
				if (!($_ -like " ") -and $_.length -ne 0) {
					Write-Host Installing $_ 
					& cmd /c """$env:ChocolateyInstall\choco.exe"" install $_ -y --ignore-checksums"
				}
			}
		} else {
			$VersionChoco = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($env:ChocolateyInstall + "\choco.exe").ProductVersion
			Write-Host Installing
			Write-Host Chocolatey v$VersionChoco
			Write-Host Package name is required. Please pass at least one package name to install.`n
		}
	}Catch{
		Write-Host $($_.Exception.Message)
	}
}

# Main

# Enable TLS 1.2 security protocol
try {
	[Net.ServicePointManager]::SecurityProtocol = [Enum]::ToObject([Net.SecurityProtocolType], 3072)
} catch [system.exception] {
	write-host "- ERROR: Could not implement TLS 1.2 Support."
	write-host "  This can occur on Windows 7 devices lacking Service Pack 1."
	write-host "  Please install that before proceeding."
}

# Check if Office or DCU should be installed
Try{
	# Check if device manufacture is Dell and if Dell Command needs to be installed
	If ((Get-ComputerInfo).CsManufacturer -match "Dell"){
		$druLocation64 = "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"
		$druLocation32 = "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"
		if(!((test-path $druLocation64) -or (test-path $druLocation32))){
			write-host "Adding Dell Command to the list of applications to install."
			$Applications += 'dellcommandupdate'		
		}else{
			write-host "Dell Command is already installed. Skipping installation."
		}
	}

	# Check if office is preinstalled
	$officeCheckC2R = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration" -Name "VersionToReport" -erroraction silentlycontinue
	if($officeCheckC2R -eq $null){
		write-host "Adding Microsoft Office to the list of applications to install."
		$Applications += 'office365business'
	}
}Catch{
	Write-Host $($_.Exception.Message)
}

# Check that the device is online before starting updates
test-networkConnection

# Start the Chocolatey install/update
InstallUpdateChoco

# Start the Chocolatey application install and exit when finished
write-host "Installing the following applications via Chocolatey:"
write-host "$applications`n"
Foreach ($app in $Applications){InstallChocoApp}
Stop-Transcript
Exit 0
