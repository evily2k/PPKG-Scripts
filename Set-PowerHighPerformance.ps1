<#
TITLE: Set-PowerHighPreformance
PURPOSE: Applying the power scheme for high preformance to the device to avoid unnecessary shutdowns
CREATOR: Dan Meddock
CREATED: 28MAR2022
LAST UPDATED: 29MAR2022
#>

# Log Windebloater output to log file
Start-Transcript -Path "C:\temp\PPKG-setHighPreformance.log"  

# Main
Try{
	# Test if the device has internet connection; if not then fail and end PPKG setup process.
	if (!(test-connection 8.8.8.8 -Count 1 -Quiet)){
    write-host "No Internet"
	Exit 1
	}else{write-host "Device is Online."}
	
	# Set High Preformance power scheme
	Write-Host "Applying High Preformance power settings..."
	powercfg.exe /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
}Catch{
	Write-Host $($_.Exception.Message)
}

Stop-Transcript

