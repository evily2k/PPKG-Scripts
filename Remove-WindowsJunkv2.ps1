<#
TITLE: Remove-WindowsJunk
PURPOSE: Used with PPKG file to remove Windows Bloatware and other junk, disable tracking, configure start menu, and more
CREATOR: Dan Meddock
CREATED: 14MAR2022
LAST UPDATED: 25APR2023
#>

# Log Remove-WindowsJunk output to log file
Start-Transcript -Path "C:\temp\PPKG-WindowsDebloater.log"

# Declarations

# Creates a PSDrive to be able to access the 'HKCR' tree
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

#no errors throughout
$ErrorActionPreference = 'silentlycontinue'

# List of apps that are blacklist to be removed when the script is executed
Function DebloatBlacklist {
	
	#Removes AppxPackages
    $WhitelistedApps = 'Microsoft.WindowsNotepad|Microsoft.CompanyPortal|Microsoft.ScreenSketch|Microsoft.Paint3D|Microsoft.WindowsCalculator|Microsoft.WindowsStore|Microsoft.Windows.Photos|CanonicalGroupLimited.UbuntuonWindows|
    Microsoft.MicrosoftStickyNotes|Microsoft.MSPaint|Microsoft.WindowsCamera|.NET|Framework|
    Microsoft.HEIFImageExtension|Microsoft.ScreenSketch|Microsoft.StorePurchaseApp|Microsoft.VP9VideoExtensions|Microsoft.WebMediaExtensions|Microsoft.WebpImageExtension|Microsoft.DesktopAppInstaller|WindSynthBerry|MIDIBerry|Slack'
    #NonRemovable Apps that where getting attempted and the system would reject the uninstall, speeds up debloat and prevents 'initalizing' overlay when removing apps
    $NonRemovable = '1527c705-839a-4832-9118-54d4Bd6a0c89|c5e2524a-ea46-4f67-841f-6a9465d9d515|E2A4F912-2574-4A75-9BB0-0D023378592B|F46D4000-FD22-4DB4-AC8E-4E1DDDE828FE|InputApp|Microsoft.AAD.BrokerPlugin|Microsoft.AccountsControl|
    Microsoft.BioEnrollment|Microsoft.CredDialogHost|Microsoft.ECApp|Microsoft.LockApp|Microsoft.MicrosoftEdgeDevToolsClient|Microsoft.MicrosoftEdge|Microsoft.PPIProjection|Microsoft.Win32WebViewHost|Microsoft.Windows.Apprep.ChxApp|
    Microsoft.Windows.AssignedAccessLockApp|Microsoft.Windows.CapturePicker|Microsoft.Windows.CloudExperienceHost|Microsoft.Windows.ContentDeliveryManager|Microsoft.Windows.Cortana|Microsoft.Windows.NarratorQuickStart|
    Microsoft.Windows.ParentalControls|Microsoft.Windows.PeopleExperienceHost|Microsoft.Windows.PinningConfirmationDialog|Microsoft.Windows.SecHealthUI|Microsoft.Windows.SecureAssessmentBrowser|Microsoft.Windows.ShellExperienceHost|
    Microsoft.Windows.XGpuEjectDialog|Microsoft.XboxGameCallableUI|Windows.CBSPreview|windows.immersivecontrolpanel|Windows.PrintDialog|Microsoft.XboxGameCallableUI|Microsoft.VCLibs.140.00|Microsoft.Services.Store.Engagement|Microsoft.UI.Xaml.2.0|*Nvidia*'
    Get-AppxPackage -AllUsers | Where-Object {$_.Name -Notin $WhitelistedApps -and $_.Name -Notin $NonRemovable} | Remove-AppxPackage
    Get-AppxPackage -allusers | Where-Object {$_.Name -Notin $WhitelistedApps -and $_.Name -Notin $NonRemovable} | Remove-AppxPackage
    Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -Notin $WhitelistedApps -and $_.PackageName -Notin $NonRemovable} | Remove-AppxProvisionedPackage -Online

    $Bloatware = @(

        # Unnecessary Windows 10 AppX Apps
        "Microsoft.BingNews"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.Messaging"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.MicrosoftOfficeHub"
        #"Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.NetworkSpeedTest"
        "Microsoft.MixedReality.Portal"
        "Microsoft.News"
        "Microsoft.Office.Lens"
        "Microsoft.Office.OneNote"
        "Microsoft.Office.Sway"
        "Microsoft.OneConnect"
        "Microsoft.People"
        "Microsoft.Print3D"
        "Microsoft.RemoteDesktop"
        "Microsoft.SkypeApp"
        "Microsoft.StorePurchaseApp"
        "Microsoft.Office.Todo.List"
        "Microsoft.Whiteboard"
        "Microsoft.WindowsAlarms"
        #"Microsoft.WindowsCamera"
        "microsoft.windowscommunicationsapps"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.WindowsMaps"
        "Microsoft.WindowsSoundRecorder"
        "Microsoft.Xbox.TCUI"
        "Microsoft.XboxApp"
        "Microsoft.XboxGameOverlay"
        "Microsoft.XboxIdentityProvider"
        "Microsoft.XboxSpeechToTextOverlay"
        "Microsoft.ZuneMusic"
        "Microsoft.ZuneVideo"

        # Sponsored Windows 10 AppX Apps
        # Add sponsored/featured apps to remove in the "*AppName*" format
        "MicrosoftTeams"
        "Microsoft.YourPhone"
        "Microsoft.XboxGamingOverlay_5.721.10202.0_neutral_~_8wekyb3d8bbwe"
        "Microsoft.GamingApp"
        "SpotifyAB.SpotifyMusic"
        "Disney.37853FC22B2CE"
        "*EclipseManager*"
        "*ActiproSoftwareLLC*"
        "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
        "*Duolingo-LearnLanguagesforFree*"
        "*PandoraMediaInc*"
        "*CandyCrush*"
        "*BubbleWitch3Saga*"
        "*Wunderlist*"
        "*Flipboard*"
        "*Twitter*"
        "*Facebook*"
        "*Spotify*"
        "*Minecraft*"
        "*Royal Revolt*"
        "*Sway*"
        "*Speed Test*"
        "*Dolby*"
        "*Office*"
        "*Disney*"
        "clipchamp.clipchamp"
        "*gaming*"
        "MicrosoftCorporationII.MicrosoftFamily"
             
    )
    foreach ($Bloat in $Bloatware) {
        Get-AppxPackage -Name $Bloat| Remove-AppxPackage
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat | Remove-AppxProvisionedPackage -Online
        Write-Output "Trying to remove $Bloat."
    }
}

# Removes Registry keys that are no longer needed
Function Remove-Keys {        
    Param([switch]$Debloat)    
    # These are the registry keys that it will delete.        
    $Keys = @(
        
        # Remove Background Tasks
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
        
        # Windows File
        "HKCR:\Extensions\ContractId\Windows.File\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        
        # Registry keys to delete if they aren't uninstalled by RemoveAppXPackage/RemoveAppXProvisionedPackage
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
        
        # Scheduled Tasks to delete
        "HKCR:\Extensions\ContractId\Windows.PreInstalledConfigTask\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
        
        # Windows Protocol Keys
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
           
        # Windows Share Target
        "HKCR:\Extensions\ContractId\Windows.ShareTarget\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
    )
    
    # This writes the output of each key it is removing and also removes the keys listed above.
    ForEach ($Key in $Keys) {
        Write-Output "Removing $Key from registry"
        Remove-Item $Key -Recurse -ErrorAction SilentlyContinue
    }
}

# Stops telemetry, disabling unneccessary scheduled tasks, and preventing bloatware from returning.      
Function Protect-Privacy {    
    Param([switch]$Debloat)
	##We need to grab all SIDs to remove at user level
	$UserSIDs = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" | Select-Object -ExpandProperty PSChildName
	
    # Creates a PSDrive to be able to access the 'HKCR' tree
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
        
    # Disables Windows Feedback Experience
    Write-Host "Disabling Windows Feedback Experience program"
    $Advertising = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
    If (!(Test-Path $Advertising)) {
        New-Item $Advertising
    }
    If (Test-Path $Advertising) {
        Set-ItemProperty $Advertising Enabled -Value 0 
    }
            
    #Stops Cortana from being used as part of your Windows Search Function
    Write-Host "Stopping Cortana from being used as part of your Windows Search Function"
    $Search = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    If (!(Test-Path $Search)) {
        New-Item $Search
    }
    If (Test-Path $Search) {
        Set-ItemProperty $Search AllowCortana -Value 0 
    }

    #Disables Web Search in Start Menu
    Write-Host "Disabling Bing Search in Start Menu"
    $WebSearch = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    If (!(Test-Path $WebSearch)) {
        New-Item $WebSearch
    }
    Set-ItemProperty $WebSearch DisableWebSearch -Value 1 
    ##Loop through all user SIDs in the registry and disable Bing Search
    foreach ($sid in $UserSIDs) {
        $WebSearch = "HKU:\$sid\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
        If (!(Test-Path $WebSearch)) {
            New-Item $WebSearch
        }
        Set-ItemProperty $WebSearch BingSearchEnabled -Value 0
    }
    
    Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" BingSearchEnabled -Value 0 
        
    #Stops the Windows Feedback Experience from sending anonymous data
    Write-Host "Stopping the Windows Feedback Experience program"
    $Period = "HKCU:\Software\Microsoft\Siuf\Rules"
    If (!(Test-Path $Period)) { 
        New-Item $Period
    }
    Set-ItemProperty $Period PeriodInNanoSeconds -Value 0 

    ##Loop and do the same
    foreach ($sid in $UserSIDs) {
        $Period = "HKU:\$sid\Software\Microsoft\Siuf\Rules"
        If (!(Test-Path $Period)) { 
            New-Item $Period
        }
        Set-ItemProperty $Period PeriodInNanoSeconds -Value 0 
    }
               
    # Prevents bloatware applications from returning and removes Start Menu suggestions               
    Write-Output "Adding Registry key to prevent bloatware apps from returning"
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    $registryOEM = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    If (!(Test-Path $registryPath)) { 
        New-Item $registryPath
    }
    Set-ItemProperty $registryPath DisableWindowsConsumerFeatures -Value 1 

    If (!(Test-Path $registryOEM)) {
        New-Item $registryOEM
    }
    Set-ItemProperty $registryOEM  ContentDeliveryAllowed -Value 0 
    Set-ItemProperty $registryOEM  OemPreInstalledAppsEnabled -Value 0 
    Set-ItemProperty $registryOEM  PreInstalledAppsEnabled -Value 0 
    Set-ItemProperty $registryOEM  PreInstalledAppsEverEnabled -Value 0 
    Set-ItemProperty $registryOEM  SilentInstalledAppsEnabled -Value 0 
    Set-ItemProperty $registryOEM  SystemPaneSuggestionsEnabled -Value 0    

	##Loop through users and do the same
    foreach ($sid in $UserSIDs) {
        $registryOEM = "HKU:\$sid\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
        If (!(Test-Path $registryOEM)) {
            New-Item $registryOEM
        }
        Set-ItemProperty $registryOEM  ContentDeliveryAllowed -Value 0 
        Set-ItemProperty $registryOEM  OemPreInstalledAppsEnabled -Value 0 
        Set-ItemProperty $registryOEM  PreInstalledAppsEnabled -Value 0 
        Set-ItemProperty $registryOEM  PreInstalledAppsEverEnabled -Value 0 
        Set-ItemProperty $registryOEM  SilentInstalledAppsEnabled -Value 0 
        Set-ItemProperty $registryOEM  SystemPaneSuggestionsEnabled -Value 0 
    }
    
	# Preping mixed Reality Portal for removal 
    Write-Output "Setting Mixed Reality Portal value to 0 so that you can uninstall it in Settings"
    $Holo = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic'    
    If (Test-Path $Holo) {
        Set-ItemProperty $Holo  FirstRunSucceeded -Value 0
    }
	
	 ##Loop through users and do the same
    foreach ($sid in $UserSIDs) {
        $Holo = "HKU:\$sid\Software\Microsoft\Windows\CurrentVersion\Holographic"    
        If (Test-Path $Holo) {
            Set-ItemProperty $Holo  FirstRunSucceeded -Value 0 
        }
    }
	
	#Disables Wi-fi Sense
    Write-Host "Disabling Wi-Fi Sense"
    $WifiSense1 = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting"
    $WifiSense2 = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots"
    $WifiSense3 = "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config"
    If (!(Test-Path $WifiSense1)) {
        New-Item $WifiSense1
    }
    Set-ItemProperty $WifiSense1  Value -Value 0 
    If (!(Test-Path $WifiSense2)) {
        New-Item $WifiSense2
    }
    Set-ItemProperty $WifiSense2  Value -Value 0 
    Set-ItemProperty $WifiSense3  AutoConnectAllowedOEM -Value 0 
    
    # Disables live tiles
    Write-Output "Disabling live tiles"
    $Live = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"    
    If (!(Test-Path $Live)) {      
        New-Item $Live
    }
    Set-ItemProperty $Live  NoTileApplicationNotification -Value 1 
	
	##Loop through users and do the same
    foreach ($sid in $UserSIDs) {
        $Live = "HKU:\$sid\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"    
        If (!(Test-Path $Live)) {      
            New-Item $Live
        }
        Set-ItemProperty $Live  NoTileApplicationNotification -Value 1 
    }
    
    # Turns off Data Collection via the AllowTelemtry key by changing it to 0
    #Write-Output "Turning off Data Collection"
    #$DataCollection1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
    #$DataCollection2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    #$DataCollection3 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"    
    #If (Test-Path $DataCollection1) {
    #    Set-ItemProperty $DataCollection1  AllowTelemetry -Value 0 
    #}
    #If (Test-Path $DataCollection2) {
    #    Set-ItemProperty $DataCollection2  AllowTelemetry -Value 0 
    #}
    #If (Test-Path $DataCollection3) {
    #    Set-ItemProperty $DataCollection3  AllowTelemetry -Value 0 
    #}
    
    # Disables People icon on Taskbar
    Write-Output "Disabling People icon on Taskbar"
    $People = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People'
    If (Test-Path $People) {
        Set-ItemProperty $People -Name PeopleBand -Value 0 -Verbose
    }
	
	##Loop through users and do the same
    foreach ($sid in $UserSIDs) {
        $People = "HKU:\$sid\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"
        If (Test-Path $People) {
            Set-ItemProperty $People -Name PeopleBand -Value 0
        }
    }
	
	Write-Host "Disabling Cortana"
    $Cortana1 = "HKCU:\SOFTWARE\Microsoft\Personalization\Settings"
    $Cortana2 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
    $Cortana3 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"
    If (!(Test-Path $Cortana1)) {
        New-Item $Cortana1
    }
    Set-ItemProperty $Cortana1 AcceptedPrivacyPolicy -Value 0 
    If (!(Test-Path $Cortana2)) {
        New-Item $Cortana2
    }
    Set-ItemProperty $Cortana2 RestrictImplicitTextCollection -Value 1 
    Set-ItemProperty $Cortana2 RestrictImplicitInkCollection -Value 1 
    If (!(Test-Path $Cortana3)) {
        New-Item $Cortana3
    }
    Set-ItemProperty $Cortana3 HarvestContacts -Value 0

    ##Loop through users and do the same
    foreach ($sid in $UserSIDs) {
        $Cortana1 = "HKU:\$sid\SOFTWARE\Microsoft\Personalization\Settings"
        $Cortana2 = "HKU:\$sid\SOFTWARE\Microsoft\InputPersonalization"
        $Cortana3 = "HKU:\$sid\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"
        If (!(Test-Path $Cortana1)) {
            New-Item $Cortana1
        }
        Set-ItemProperty $Cortana1 AcceptedPrivacyPolicy -Value 0 
        If (!(Test-Path $Cortana2)) {
            New-Item $Cortana2
        }
        Set-ItemProperty $Cortana2 RestrictImplicitTextCollection -Value 1 
        Set-ItemProperty $Cortana2 RestrictImplicitInkCollection -Value 1 
        If (!(Test-Path $Cortana3)) {
            New-Item $Cortana3
        }
        Set-ItemProperty $Cortana3 HarvestContacts -Value 0
    }
	
	#Removes 3D Objects from the 'My Computer' submenu in explorer
    Write-Host "Removing 3D Objects from explorer 'My Computer' submenu"
    $Objects32 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
    $Objects64 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
    If (Test-Path $Objects32) {
        Remove-Item $Objects32 -Recurse 
    }
    If (Test-Path $Objects64) {
        Remove-Item $Objects64 -Recurse 
    }
	
	##Removes the Microsoft Feeds from displaying
	$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds"
	$Name = "EnableFeeds"
	$value = "0"
	
	if (!(Test-Path $registryPath)) {
		New-Item -Path $registryPath -Force | Out-Null
		New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
	}else{
		New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
	}
	
    # Disables suggestions on start menu
    Write-Output "Disabling suggestions on the Start Menu"
    $Suggestions = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'    
    If (Test-Path $Suggestions) {
        Set-ItemProperty $Suggestions -Name SystemPaneSuggestionsEnabled -Value 0 -Verbose
    }
    
    # Loads the registry keys/values below into the NTUSER.DAT file which prevents the apps from redownloading. Credit to a60wattfish
    reg load HKU\Default_User C:\Users\Default\NTUSER.DAT
    Set-ItemProperty -Path Registry::HKU\Default_User\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name SystemPaneSuggestionsEnabled -Value 0
    Set-ItemProperty -Path Registry::HKU\Default_User\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name PreInstalledAppsEnabled -Value 0
    Set-ItemProperty -Path Registry::HKU\Default_User\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name OemPreInstalledAppsEnabled -Value 0
    reg unload HKU\Default_User
    
    # Disables scheduled tasks that are considered unnecessary 
    Write-Output "Disabling scheduled tasks"
    Get-ScheduledTask -TaskName XblGameSaveTaskLogon -ErrorAction SilentlyContinue | Disable-ScheduledTask -ErrorAction SilentlyContinue
    Get-ScheduledTask -TaskName XblGameSaveTask | Disable-ScheduledTask -ErrorAction SilentlyContinue
    Get-ScheduledTask -TaskName Consolidator | Disable-ScheduledTask -ErrorAction SilentlyContinue
    Get-ScheduledTask -TaskName UsbCeip | Disable-ScheduledTask -ErrorAction SilentlyContinue
    Get-ScheduledTask -TaskName DmClient | Disable-ScheduledTask -ErrorAction SilentlyContinue
    Get-ScheduledTask -TaskName DmClientOnScenarioDownload | Disable-ScheduledTask -ErrorAction SilentlyContinue
	
	Write-Host "Stopping and disabling Diagnostics Tracking Service"
    #Disabling the Diagnostics Tracking Service
    Stop-Service "DiagTrack"
    Set-Service "DiagTrack" -StartupType Disabled
}

# This includes fixes by xsisbest
Function FixWhitelistedApps {    
    Param([switch]$Debloat)    
    If(!(Get-AppxPackage -AllUsers | Select Microsoft.Paint3D, Microsoft.MSPaint, Microsoft.WindowsCalculator, Microsoft.WindowsStore, Microsoft.MicrosoftStickyNotes, Microsoft.WindowsSoundRecorder, Microsoft.Windows.Photos)) {    
		# Credit to abulgatz for the 4 lines of code
		Get-AppxPackage -allusers Microsoft.Paint3D | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
		Get-AppxPackage -allusers Microsoft.MSPaint | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
		Get-AppxPackage -allusers Microsoft.WindowsCalculator | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
		Get-AppxPackage -allusers Microsoft.WindowsStore | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
		Get-AppxPackage -allusers Microsoft.MicrosoftStickyNotes | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
		Get-AppxPackage -allusers Microsoft.WindowsSoundRecorder | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
		Get-AppxPackage -allusers Microsoft.Windows.Photos | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"} 
	}
}

Function RemoveWindows11Specific{
	
	#Windows 11 Customisations
    write-host "Removing Windows 11 Customisations"
    #Remove XBox Game Bar
    
    Get-AppxPackage -allusers Microsoft.XboxGamingOverlay | Remove-AppxPackage
    write-host "Removed Xbox Gaming Overlay"
    Get-AppxPackage -allusers Microsoft.XboxGameCallableUI | Remove-AppxPackage
    write-host "Removed Xbox Game Callable UI"

    #Remove Cortana
    Get-AppxPackage -allusers Microsoft.549981C3F5F10 | Remove-AppxPackage
    write-host "Removed Cortana"

    #Remove GetStarted
    Get-AppxPackage -allusers *getstarted* | Remove-AppxPackage
    write-host "Removed Get Started"

    #Remove Parental Controls
    Get-AppxPackage -allusers Microsoft.Windows.ParentalControls | Remove-AppxPackage 
    write-host "Removed Parental Controls"

    #Remove Teams Chat
	$MSTeams = "MicrosoftTeams"

	$WinPackage = Get-AppxPackage -allusers | Where-Object {$_.Name -eq $MSTeams}
	$ProvisionedPackage = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $WinPackage }
	If ($null -ne $WinPackage) 
	{
		Remove-AppxPackage  -Package $WinPackage.PackageFullName
	} 

	If ($null -ne $ProvisionedPackage) 
	{
		Remove-AppxProvisionedPackage -online -Packagename $ProvisionedPackage.Packagename
	}

	##Stop it coming back
	$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications"
	If (!(Test-Path $registryPath)) { 
		New-Item $registryPath
	}
	Set-ItemProperty $registryPath ConfigureChatAutoInstall -Value 0


	##Unpin it
	$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat"
	If (!(Test-Path $registryPath)) { 
		New-Item $registryPath
	}
	Set-ItemProperty $registryPath "ChatIcon" -Value 2
	write-host "Removed Teams Chat"
	
}

function scheduleRegTweaks {
	# powershell script used in scheduled task
	$installScript = "C:\Temp\runRegTweaks.ps1"
	write-host "Scheduling Registry tweaks to run after next reboot."

# Commands to run Dell Command and apply updates
$installCommand = @'
$installScript = "C:\Temp\runRegTweaks.ps1"
Start-transcript -Path "C:\temp\PPKG-regTweaks.log"
##Tweak reg permissions
invoke-webrequest -uri "https://github.com/evily2k/PPKG-Scripts/raw/main/SetACL.exe" -outfile "C:\Windows\Temp\SetACL.exe"
Sleep 5
C:\Windows\Temp\SetACL.exe -on "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications" -ot reg -actn setowner -ownr "n:Everyone"
C:\Windows\Temp\SetACL.exe -on "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications" -ot reg -actn ace -ace "n:Everyone;p:full"
Sleep 15
Remove-Item C:\Windows\Temp\SetACL.exe -recurse
Unregister-ScheduledTask -TaskName "regTweaks" -Confirm:$false
Remove-Item -Path $installScript -Force
Stop-Transcript
Exit 0
'@

	# Output scriptblock to directory
	$installCommand | out-file $installScript

	# Create Scheduled task
	$taskname = "regTweaks"
	$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-executionpolicy bypass -noprofile -file $installScript"
	$trigger = New-ScheduledTaskTrigger -AtStartup -RandomDelay 00:00:30
	$principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
	$task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal
	Register-ScheduledTask $taskname -InputObject $task
	Write-Host "Registry tweaks will be made after the next reboot."
}

# Checks the Device Management Wireless Application Protocol (WAP) Push Message Routing Service is enabled and will enable if not
Function CheckDMWService {
  Param([switch]$Debloat)  
	If (Get-Service -Name dmwappushservice | Where-Object {$_.StartType -eq "Disabled"}) {
		Set-Service -Name dmwappushservice -StartupType Automatic}

	If(Get-Service -Name dmwappushservice | Where-Object {$_.Status -eq "Stopped"}) {
	   Start-Service -Name dmwappushservice} 
}

# This service provides infrastructure support for the Microsoft Store
Function CheckInstallService {
  Param([switch]$Debloat)
	If (Get-Service -Name InstallService | Where-Object {$_.Status -eq "Stopped"}) {  
		Start-Service -Name InstallService
		Set-Service -Name InstallService -StartupType Automatic 
	}
}

Function removeOffice {
	$OfficeInstallDownloadPath = "C:\temp\Office365Install"

	Function Generate-XMLFile{
	  #XML data that will be used for the download/install
	  $OfficeXML = [XML]@"
	  <Configuration>
		<!--Uninstall complete Office 365-->
		<Display Level="None" AcceptEULA="TRUE" />
		<Logging Level="Standard" Path="%temp%" />
		<Remove All="TRUE" />
	  </Configuration>
"@
	  #Save the XML file
	  $OfficeXML.Save("$OfficeInstallDownloadPath\OfficeInstall.xml")
	  Return "$OfficeInstallDownloadPath\OfficeInstall.xml"
	}
	Function Test-URL{
	  Param(
		$CurrentURL
	  )

	  Try{
		$HTTPRequest = [System.Net.WebRequest]::Create($CurrentURL)
		$HTTPResponse = $HTTPRequest.GetResponse()
		$HTTPStatus = [Int]$HTTPResponse.StatusCode

		If($HTTPStatus -ne 200) {
		  Return $False
		}

		$HTTPResponse.Close()

	  }Catch{
		  Return $False
	  }	
	  Return $True
	}
	Function Get-ODTURL {
	  $ODTDLLink = "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_12130-20272.exe"

	  If((Test-URL -CurrentURL $ODTDLLink) -eq $False){
		$MSWebPage = (Invoke-WebRequest "https://www.microsoft.com/en-us/download/confirmation.aspx?id=49117" -UseBasicParsing).Content
	  
		#Thank you reddit user, u/sizzlr for this addition.
		$MSWebPage | ForEach-Object {
		  If ($_ -match "url=(https://.*officedeploymenttool.*\.exe)"){
			$ODTDLLink = $matches[1]}
		  }
	  }
	  Return $ODTDLLink
	}

	$VerbosePreference = "Continue"
	$ErrorActionPreference = "Stop"

	If(-Not(Test-Path $OfficeInstallDownloadPath )){
	  New-Item -Path $OfficeInstallDownloadPath  -ItemType Directory -ErrorAction Stop | Out-Null
	}

	If(!($ConfigurationXMLFile)){ #If the user didn't specify with -ConfigurationXMLFile param, we make one!
	  $ConfigurationXMLFile = Generate-XMLFile
	}Else{
	  If(!(Test-Path $ConfigurationXMLFile)){
		Write-Warning "The configuration XML file is not a valid file"
		Write-Warning "Please check the path and try again"
		Exit
	  }
	}

	#Get the ODT Download link
	$ODTInstallLink = Get-ODTURL

	#Download the Office Deployment Tool
	Write-Verbose "Downloading the Office Deployment Tool..."
	Try{
	  Invoke-WebRequest -Uri $ODTInstallLink -OutFile "$OfficeInstallDownloadPath\ODTSetup.exe"
	}Catch{
	  Write-Warning "There was an error downloading the Office Deployment Tool."
	  Write-Warning "Please verify the below link is valid:"
	  Write-Warning $ODTInstallLink
	  Exit
	}

	#Run the Office Deployment Tool setup
	Try{
	  Write-Verbose "Running the Office Deployment Tool..."
	  Start-Process "$OfficeInstallDownloadPath\ODTSetup.exe" -ArgumentList "/quiet /extract:$OfficeInstallDownloadPath" -Wait
	}Catch{
	  Write-Warning "Error running the Office Deployment Tool. The error is below:"
	  Write-Warning $_
	}

	#Run the O365 install
	Try{
	  Write-Verbose "Removing Pre-Install Office apps..."
	  $OfficeInstall = Start-Process -WindowStyle hidden "$OfficeInstallDownloadPath\Setup.exe" -ArgumentList "/configure $ConfigurationXMLFile" -Wait -PassThru
	}Catch{
	  Write-Warning "Error running the Office install. The error is below:"
	  Write-Warning $_
	}

	#Check if Office 365 is installed.
	$RegLocations = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
					  'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
					 )

	$OfficeInstalled = $False
	Foreach ($Key in (Get-ChildItem $RegLocations) ) {
	  If($Key.GetValue("DisplayName") -like "*Office 365*") {
		$OfficeVersionInstalled = $Key.GetValue("DisplayName")
		$OfficeInstalled = $True
	  }
	}

	If($OfficeInstalled){
	  Write-Verbose "$($OfficeVersionInstalled) installed successfully!"
	}Else{
	  Write-Warning "Office 365 was not detected after the install ran"
	}
	Sleep 45
	# Delete the install files when finished
	Remove-Item $OfficeInstallDownloadPath -Recurse -Force
}

# Configures the Windows start menu and cleans up junk
Function UnpinStart {

#Check windows version
$version = Get-WMIObject win32_operatingsystem | Select-Object Caption
	if ($version.Caption -like "*Windows 10*") {
		write-host "Windows 10 Detected"

$START_MENU_LAYOUT = @"
<LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
    <LayoutOptions StartTileGroupCellWidth="6" />
    <DefaultLayoutOverride>
        <StartLayoutCollection>
            <defaultlayout:StartLayout GroupCellWidth="6" />
        </StartLayoutCollection>
    </DefaultLayoutOverride>
</LayoutModificationTemplate>
"@

    $layoutFile="C:\Windows\StartMenuLayout.xml"

    # Delete layout file if it already exists
    If(Test-Path $layoutFile){Remove-Item $layoutFile}

    # Creates the blank layout file
    $START_MENU_LAYOUT | Out-File $layoutFile -Encoding ASCII

    $regAliases = @("HKLM", "HKCU")

    # Assign the start layout and force it to apply with "LockedStartLayout" at both the machine and user level
    foreach ($regAlias in $regAliases){
        $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
        $keyPath = $basePath + "\Explorer" 
        If(!(Test-Path -Path $keyPath)) { 
            New-Item -Path $basePath -Name "Explorer"
        }
        Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 1
        Set-ItemProperty -Path $keyPath -Name "StartLayoutFile" -Value $layoutFile
    }

    # Enable the ability to pin items again by disabling "LockedStartLayout"
    foreach ($regAlias in $regAliases){
        $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
        $keyPath = $basePath + "\Explorer" 
        Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 0
    }

    # Make clean start menu default for all new users
    Import-StartLayout -LayoutPath $layoutFile -MountPath $env:SystemDrive\

    Remove-Item $layoutFile
	}
	if ($version.Caption -like "*Windows 11*") {
    write-host "Windows 11 Detected"
    write-host "Removing Current Layout"
    If(Test-Path "C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml")

    {
    
    Remove-Item "C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml"
    
    }
    
$blankjson = @'
{ 
    "pinnedList": [ 
      { "desktopAppId": "MSEdge" }, 
      { "packagedAppId": "Microsoft.WindowsStore_8wekyb3d8bbwe!App" }, 
      { "packagedAppId": "desktopAppId":"Microsoft.Windows.Explorer" } 
    ] 
  }
'@

	$blankjson | Out-File "C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml" -Encoding utf8 -Force
	}
}

# Removes 3D Objects from the 'My Computer' submenu in explorer
Function Remove3dObjects {
    Write-Host "Removing 3D Objects from explorer 'My Computer' submenu"
    $Objects32 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
    $Objects64 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
    If (Test-Path $Objects32) {
        Remove-Item $Objects32 -Recurse 
    }
    If (Test-Path $Objects64) {
        Remove-Item $Objects64 -Recurse 
    }
}

Function removeXboxGaming{	
	New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\xbgm" -Name "Start" -PropertyType DWORD -Value 4 -Force
	Set-Service -Name XblAuthManager -StartupType Disabled
	Set-Service -Name XblGameSave -StartupType Disabled
	Set-Service -Name XboxGipSvc -StartupType Disabled
	Set-Service -Name XboxNetApiSvc -StartupType Disabled
	$task = Get-ScheduledTask -TaskName "Microsoft\XblGameSave\XblGameSaveTask" -ErrorAction SilentlyContinue
	if ($null -ne $task) {
		Set-ScheduledTask -TaskPath $task.TaskPath -Enabled $false
	}
	Take-Ownership -Path "$env:WinDir\System32\GameBarPresenceWriter.exe"
	Set-Acl -Path "$env:WinDir\System32\GameBarPresenceWriter.exe" -AclObject (Get-Acl -Path "$env:WinDir\System32\GameBarPresenceWriter.exe").SetAccessRuleProtection($true, $true) -InheritanceFlags "None" -AddAccessRule (New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow"))
	Stop-Process -Name "GameBarPresenceWriter.exe" -Force
	Remove-Item "$env:WinDir\System32\GameBarPresenceWriter.exe" -Force -Confirm:$false
	New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\GameDVR" -Name "AllowgameDVR" -PropertyType DWORD -Value 0 -Force
	New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "SettingsPageVisibility" -PropertyType String -Value "hide:gaming-gamebar;gaming-gamedvr;gaming-broadcasting;gaming-gamemode;gaming-xboxnetworking" -Force	
	
	$surf = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge"
	If (!(Test-Path $surf)) {
		New-Item $surf
	}
	New-ItemProperty -Path $surf -Name 'AllowSurfGame' -Value 0 -PropertyType DWord
}

# Set Windows to Dark Mode
Function SetWindowstoDarkMode {
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes" /f
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes" /v "AppsUseLightTheme" /t "REG_DWORD" /d "0" /f
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes" /v "SystemUsesLightTheme" /t "REG_DWORD" /d "0" /f
	reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes" /f
	reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /f
	reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t "REG_DWORD" /d "0" /f
	reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "SystemUsesLightTheme" /t "REG_DWORD" /d "0" /f
	reg add "HKEY_USERS\.DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes" /f
	reg add "HKEY_USERS\.DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /f
	reg add "HKEY_USERS\.DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t "REG_DWORD" /d "0" /f
	reg add "HKEY_USERS\.DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "SystemUsesLightTheme" /t "REG_DWORD" /d "0" /f
}

# Disable 'Updates are available' message
Function DisableUpdatesAvailable {
	Write-Host "Disable 'Updates are available' message"
	takeown /F "$env:WinDIR\System32\MusNotification.exe"
	icacls "$env:WinDIR\System32\MusNotification.exe" /deny "$($EveryOne):(X)"
	takeown /F "$env:WinDIR\System32\MusNotificationUx.exe"
	icacls "$env:WinDIR\System32\MusNotificationUx.exe" /deny "$($EveryOne):(X)"
}

# This function will remove the Dell bloatware
function remove-OEMBloat{
	
		##Check Manufacturer
		write-host "Detecting Manufacturer"
		$details = Get-CimInstance -ClassName Win32_ComputerSystem
		$manufacturer = $details.Manufacturer

		if ($manufacturer -like "*HP*") {
			Write-Host "HP detected"
			#Remove HP bloat

		##HP Specific
		$UninstallPrograms = @(
			"HP Client Security Manager"
			"HP Notifications"
			"HP Security Update Service"
			"HP System Default Settings"
			"HP Wolf Security"
			"HP Wolf Security Application Support for Sure Sense"
			"HP Wolf Security Application Support for Windows"
			"AD2F1837.HPPCHardwareDiagnosticsWindows"
			"AD2F1837.HPPowerManager"
			"AD2F1837.HPPrivacySettings"
			"AD2F1837.HPQuickDrop"
			"AD2F1837.HPSupportAssistant"
			"AD2F1837.HPSystemInformation"
			"AD2F1837.myHP"
			"RealtekSemiconductorCorp.HPAudioControl",
			"HP Sure Recover",
			"HP Sure Run Module"

		)

		$HPidentifier = "AD2F1837"

		$InstalledPackages = Get-AppxPackage -AllUsers | Where-Object {($UninstallPackages -contains $_.Name) -or ($_.Name -match "^$HPidentifier")}

		$ProvisionedPackages = Get-AppxProvisionedPackage -Online | Where-Object {($UninstallPackages -contains $_.DisplayName) -or ($_.DisplayName -match "^$HPidentifier")}

		$InstalledPrograms = Get-Package | Where-Object {$UninstallPrograms -contains $_.Name}

		# Remove provisioned packages first
		ForEach ($ProvPackage in $ProvisionedPackages) {

			Write-Host -Object "Attempting to remove provisioned package: [$($ProvPackage.DisplayName)]..."

			Try {
				$Null = Remove-AppxProvisionedPackage -PackageName $ProvPackage.PackageName -Online -ErrorAction Stop
				Write-Host -Object "Successfully removed provisioned package: [$($ProvPackage.DisplayName)]"
			}
			Catch {Write-Warning -Message "Failed to remove provisioned package: [$($ProvPackage.DisplayName)]"}
		}

		# Remove appx packages
		ForEach ($AppxPackage in $InstalledPackages) {
													
			Write-Host -Object "Attempting to remove Appx package: [$($AppxPackage.Name)]..."

			Try {
				$Null = Remove-AppxPackage -Package $AppxPackage.PackageFullName -AllUsers -ErrorAction Stop
				Write-Host -Object "Successfully removed Appx package: [$($AppxPackage.Name)]"
			}
			Catch {Write-Warning -Message "Failed to remove Appx package: [$($AppxPackage.Name)]"}
		}

		# Remove installed programs
		$InstalledPrograms | ForEach-Object {

			Write-Host -Object "Attempting to uninstall: [$($_.Name)]..."

			Try {
				$Null = $_ | Uninstall-Package -AllVersions -Force -ErrorAction Stop
				Write-Host -Object "Successfully uninstalled: [$($_.Name)]"
			}
			Catch {Write-Warning -Message "Failed to uninstall: [$($_.Name)]"}
		}


		#Remove HP Documentation
		$A = Start-Process -FilePath "C:\Program Files\HP\Documentation\Doc_uninstall.cmd" -Wait -passthru -NoNewWindow;$a.ExitCode

		##Remove Standard HP apps via msiexec
		$InstalledPrograms | ForEach-Object {
		$appname = $_.Name
			Write-Host -Object "Attempting to uninstall: [$($_.Name)]..."

			Try {
				$Prod = Get-WMIObject -Classname Win32_Product | Where-Object Name -Match $appname
				$Prod.UnInstall()
				Write-Host -Object "Successfully uninstalled: [$($_.Name)]"
			}
			Catch {Write-Warning -Message "Failed to uninstall: [$($_.Name)]"}
		}

		##Remove HP Connect Optimizer
		invoke-webrequest -uri "https://raw.githubusercontent.com/evily2k/PPKG-Scripts/main/HPConnOpt.iss" -outfile "C:\Windows\Temp\HPConnOpt.iss"

		&'C:\Program Files (x86)\InstallShield Installation Information\{6468C4A5-E47E-405F-B675-A70A70983EA6}\setup.exe' @('-s', '-f1C:\Windows\Temp\HPConnOpt.iss')

		Write-Host "Removed HP bloat"
		}
		
		if ($manufacturer -like "*Dell*") {
			Write-Host "Dell detected"
			#Remove Dell bloat

			##Dell

			$UninstallPrograms = @(
				"Dell Optimizer"
				"Dell Power Manager"
				"DellOptimizerUI"
				"Dell SupportAssist OS Recovery"
				"Dell SupportAssist"
				"Dell Optimizer Service"
				"DellInc.PartnerPromo"
				"DellInc.DellOptimizer"
				"DellInc.DellCommandUpdate"
			)

			$WhitelistedApps = @(
				"WavesAudio.MaxxAudioProforDell2019"
				"Dell - Extension*"
				"Dell, Inc. - Firmware*"
			)

			$InstalledPackages = Get-AppxPackage -AllUsers | Where-Object {(($_.Name -in $UninstallPrograms) -or ($_.Name -like "*Dell*")) -and ($_.Name -NotMatch $WhitelistedApps)}

			$ProvisionedPackages = Get-AppxProvisionedPackage -Online | Where-Object {(($_.Name -in $UninstallPrograms) -or ($_.Name -like "*Dell*")) -and ($_.Name -NotMatch $WhitelistedApps)}

			$InstalledPrograms = Get-Package | Where-Object {(($_.Name -in $UninstallPrograms) -or ($_.Name -like "*Dell*")) -and ($_.Name -NotMatch $WhitelistedApps)}
			# Remove provisioned packages first
			ForEach ($ProvPackage in $ProvisionedPackages) {

				Write-Host -Object "Attempting to remove provisioned package: [$($ProvPackage.DisplayName)]..."

				Try {
					$Null = Remove-AppxProvisionedPackage -PackageName $ProvPackage.PackageName -Online -ErrorAction Stop
					Write-Host -Object "Successfully removed provisioned package: [$($ProvPackage.DisplayName)]"
				}Catch {Write-Warning -Message "Failed to remove provisioned package: [$($ProvPackage.DisplayName)]"}
			}

			# Remove appx packages
			ForEach ($AppxPackage in $InstalledPackages) {
														
				Write-Host -Object "Attempting to remove Appx package: [$($AppxPackage.Name)]..."

				Try {
					$Null = Remove-AppxPackage -Package $AppxPackage.PackageFullName -AllUsers -ErrorAction Stop
					Write-Host -Object "Successfully removed Appx package: [$($AppxPackage.Name)]"
				}Catch {Write-Warning -Message "Failed to remove Appx package: [$($AppxPackage.Name)]"}
			}

			# Remove any bundled packages
			ForEach ($AppxPackage in $InstalledPackages) {
														
				Write-Host -Object "Attempting to remove Appx package: [$($AppxPackage.Name)]..."

				Try {
					$null = Get-AppxPackage -AllUsers -PackageTypeFilter Main, Bundle, Resource -Name $AppxPackage.Name | Remove-AppxPackage -AllUsers
					Write-Host -Object "Successfully removed Appx package: [$($AppxPackage.Name)]"
				}Catch {Write-Warning -Message "Failed to remove Appx package: [$($AppxPackage.Name)]"}
			}


			# Remove installed programs
			$InstalledPrograms | ForEach-Object {

				Write-Host -Object "Attempting to uninstall: [$($_.Name)]..."

				Try {
					$Null = $_ | Uninstall-Package -AllVersions -Force -ErrorAction Stop
					Write-Host -Object "Successfully uninstalled: [$($_.Name)]"
				}Catch{Write-Warning -Message "Failed to uninstall: [$($_.Name)]"}
			}

		}else{
			Write-host "Computer is not Dell or HP."
	}
}

Function removeExtraCrap {
	
	#McAfee

	write-host "Detecting McAfee"
	$mcafeeinstalled = "false"
	$InstalledSoftware = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
	foreach($obj in $InstalledSoftware){
		 $name = $obj.GetValue('DisplayName')
		 if ($name -like "*McAfee*") {
			 $mcafeeinstalled = "true"
		 }
	}

	$InstalledSoftware32 = Get-ChildItem "HKLM:\Software\WOW6432NODE\Microsoft\Windows\CurrentVersion\Uninstall"
	foreach($obj32 in $InstalledSoftware32){
		 $name32 = $obj32.GetValue('DisplayName')
		 if ($name32 -like "*McAfee*") {
			 $mcafeeinstalled = "true"
		 }
	}

	if ($mcafeeinstalled -eq "true") {
		Write-Host "McAfee detected"
		#Remove McAfee bloat
	##McAfee
	### Download McAfee Consumer Product Removal Tool ###
	write-host "Downloading McAfee Removal Tool"
	# Download Source
	$URL = 'https://github.com/evily2k/PPKG-Scripts/raw/main/mcafeeclean.zip'

	# Set Save Directory
	$destination = 'C:\temp\mcafee.zip'

	#Download the file
	Invoke-WebRequest -Uri $URL -OutFile $destination -Method Get
	  
	Expand-Archive $destination -DestinationPath "C:\ProgramData\Debloat" -Force

	write-host "Removing McAfee"
	# Automate Removal and kill services
	start-process "C:\ProgramData\Debloat\Mccleanup.exe" -ArgumentList "-p StopServices,MFSY,PEF,MXD,CSP,Sustainability,MOCP,MFP,APPSTATS,Auth,EMproxy,FWdiver,HW,MAS,MAT,MBK,MCPR,McProxy,McSvcHost,VUL,MHN,MNA,MOBK,MPFP,MPFPCU,MPS,SHRED,MPSCU,MQC,MQCCU,MSAD,MSHR,MSK,MSKCU,MWL,NMC,RedirSvc,VS,REMEDIATION,MSC,YAP,TRUEKEY,LAM,PCB,Symlink,SafeConnect,MGS,WMIRemover,RESIDUE -v -s"
	write-host "McAfee Removal Tool has been run"

	}


	##Look for anything else

	##Make sure Intune hasn't installed anything so we don't remove installed apps

	$intunepath = "HKLM:\SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps"
	$intunecomplete = @(Get-ChildItem $intunepath).count
	if ($intunecomplete -eq 0) {


		##Apps to ignore - NOTE: Chrome has an unusual uninstall so sort on it's own
		$whitelistapps = @(
			"Microsoft Update Health Tools"
			"Microsoft Intune Management Extension"
			"Microsoft Edge"
			"Microsoft Edge Update"
			"Microsoft Edge WebView2 Runtime"
			"Google Chrome"
			"Microsoft Teams"
			"Teams Machine-Wide Installer"
		)

		$InstalledSoftware = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
		foreach($obj in $InstalledSoftware){
			 $name = $obj.GetValue('DisplayName')
			 if (($whitelistapps -notcontains $name) -and ($null -ne $obj.GetValue('UninstallString'))) {
				$uninstallcommand = $obj.GetValue('UninstallString')
				write-host "Uninstalling $name"
				if ($uninstallcommand -like "*msiexec*") {
				$splitcommand = $uninstallcommand.Split("{")
				$msicode = $splitcommand[1]
				$uninstallapp = "msiexec.exe /X {$msicode /qn"
				start-process "cmd.exe" -ArgumentList "/c $uninstallapp"
				}
				else {
				$splitcommand = $uninstallcommand.Split("{")
				
				$uninstallapp = "$uninstallcommand /S"
				start-process "cmd.exe" -ArgumentList "/c $uninstallapp"
				}
			 }

			 }


		$InstalledSoftware32 = Get-ChildItem "HKLM:\Software\WOW6432NODE\Microsoft\Windows\CurrentVersion\Uninstall"
		foreach($obj32 in $InstalledSoftware32){
			 $name32 = $obj32.GetValue('DisplayName')
			 if (($whitelistapps -notcontains $name32) -and ($null -ne $obj32.GetValue('UninstallString'))) {
				$uninstallcommand32 = $obj.GetValue('UninstallString')
				write-host "Uninstalling $name"
				if ($uninstallcommand32 -like "*msiexec*") {
					$splitcommand = $uninstallcommand32.Split("{")
					$msicode = $splitcommand[1]
					$uninstallapp = "msiexec.exe /X {$msicode /qn"
					start-process "cmd.exe" -ArgumentList "/c $uninstallapp"
				}else {
					$splitcommand = $uninstallcommand32.Split("{")				
					$uninstallapp = "$uninstallcommand /S"
					start-process "cmd.exe" -ArgumentList "/c $uninstallapp"
				}
			}
		}

		##Remove Chrome
		$chrome32path = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Google Chrome"

		if ($null -ne $chrome32path) {

			$versions = (Get-ItemProperty -path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Google Chrome').version
			ForEach ($version in $versions) {
				write-host "Found Chrome version $version"
				$directory = ${env:ProgramFiles(x86)}
				write-host "Removing Chrome"
				Start-Process "$directory\Google\Chrome\Application\$version\Installer\setup.exe" -argumentlist  "--uninstall --multi-install --chrome --system-level --force-uninstall"
			}

		}

		$chromepath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Google Chrome"

		if ($null -ne $chromepath) {

			$versions = (Get-ItemProperty -path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Google Chrome').version
			ForEach ($version in $versions) {
				write-host "Found Chrome version $version"
				$directory = ${env:ProgramFiles}
				write-host "Removing Chrome"
				Start-Process "$directory\Google\Chrome\Application\$version\Installer\setup.exe" -argumentlist  "--uninstall --multi-install --chrome --system-level --force-uninstall"
			}


		}

	}
	
}

# Main

# Run functions
Write-Host "Removing Pre-Installed Office Apps"
removeOffice
Write-Host "Removing Blacklisted apps."
DebloatBlacklist
Write-Host "Removing leftover bloatware registry keys."
Remove-Keys
Write-Host "Checking to see if any Whitelisted Apps were removed, and if so re-adding them."
FixWhitelistedApps
Write-Host "Removing Windows 11 Specific Apps."
RemoveWindows11Specific
Write-Host "Stopping telemetry, disabling unneccessary scheduled tasks, and preventing bloatware from returning."
Protect-Privacy
Write-Host "Schedule task to run registry tweaks at next reboot."
scheduleRegTweaks
Write-host "Checking DWService to prevents SYSPREP from freezing at 'Getting Ready' on first boot"
CheckDMWService
Write-Host "Checking system services are running and setup correctly."
CheckInstallService
Write-Host "Cleaning up startmenu layout and apps."
UnpinStart
Write-Host "Removes 3D Objects from the 'My Computer' submenu"
Remove3dObjects
Write-Host "Remove Xbox Gaming from the computer."
removeXboxGaming
Write-Host "Set Windows to Dark Mode"
SetWindowstoDarkMode
Write-Host "Disable 'Updates are available' message"
DisableUpdatesAvailable
Write-Host "This will remove the Dell and HP bloatware"
remove-OEMBloat
Write-Host "Remove any extra software that may be left over."
removeExtraCrap
Write-Host "Finished all tasks."
Stop-Transcript
Exit 0