# NAME: Daniel S Callegari
# ITMD

# Variables for later use
# Array to store selected printers
[System.Collections.ArrayList]$PrinterRemoveList = @()
[System.Collections.ArrayList]$DriverRemoveList = @()
# Variables for y/n choice inputs
$title    = 'SELECTED'
$question = 'Remove from computer?'
$choices  = '&Yes', '&No'

# Writes to PowerShell explaining application purpose
Write-Host "This application will assist with the removal of printers and their associated drivers. Please be aware, any removed devices will need to be reinstalled properly once removed."

# Output list of printers with associated drivers
Get-Printer | Format-List Name,DriverName

# Take user input of printer for removal
# Uses do-while loop to ensure valid entry is found
do {

    $PrintModel = Read-Host -Prompt 'From the list, enter printer model for removal'
    
    # Check if entry is null and loops
    if ([string]::IsNullOrWhiteSpace($PrintModel)) {
        Write-Host "Blank entry, please enter valid printer from above list."
    }
    # Takes input and appends * to accomodate for incomplete entry
    # i.e.- User enters just HP, will check for all HP printers
    else {
        $PrintModel = $PrintModel + "*"
        break
    }

} while ($true)

# Stores narrowed list of printers based on user input
$SelectPrinters = Get-Printer -Name $PrintModel

# Checks each printer down list for which to remove
foreach ($Printer in $SelectPrinters) {

    # Output printer list item
    Get-Printer -Name $Printer.Name | Format-List Name,DriverName
    
    # Prompt Yes/No choice, defaults to No
    $Ans = $Host.UI.PromptForChoice($title,$question,$choices,1)
    
    if ($Ans -eq 0) {

        Write-Host "Printer added to list for removal."
        
        # Stores printer name in list
        $PrinterRemoveList.Add($Printer.Name) | Out-Null
        
        # Uses temporary variable for driver
        $Temp = $Printer.DriverName

        # Checks if list already has driver before adding 
        # to list to reduce duplicate entries
        if ($DriverRemoveList -notcontains $Temp) {
            $DriverRemoveList.Add($Temp) | Out-Null
        }

    } else {
        Write-Host "Printer skipped."
    }

}

# Used to troubleshoot list testing
# Write-Host $PrinterRemoveList
# Write-Host $DriverRemoveList

# Loop to remove each printer/driver in lists, 
# outputs confirmation line per entry
foreach ($Printer in $PrinterRemoveList) {
    Remove-Printer -Name $Printer
    Write-Host "Uninstalled" $Printer "from machine."
}

foreach ($Driver in $DriverRemoveList) {
    Remove-PrinterDriver -Name $Driver
    Write-Host $Driver "removed successfully."
}
