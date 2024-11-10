<#
.SYNOPSIS
    Manages static Azure AD groups by adding devices from Intune to these groups.

.DESCRIPTION
    This PowerShell script automates the management of static Azure Active Directory (Azure AD) groups by integrating with Microsoft Intune and Microsoft Graph. 
    It performs the following key functions:
    
    - **Connection Setup**: Establishes connections to Microsoft Graph and Azure AD using the necessary modules.
    - **Group Management**: 
        - Identifies existing static groups with a specified prefix.
        - Creates new groups if existing ones do not cover all devices.
        - Ensures that each group does not exceed a predefined member limit (default is 500 members).
    - **Device Assignment**: Retrieves devices from Intune and distributes them across the managed groups, maintaining the member limit per group.
    - **Logging**: Optionally logs all actions and events to a specified log file for auditing and troubleshooting purposes.
    
    The script is designed to handle large numbers of devices efficiently by batching operations and providing informative logging. It ensures that group memberships remain organized and within Azure AD's constraints.

.NOTES
    - **Permissions**: Ensure the script is executed with appropriate permissions to access Microsoft Graph and Azure AD. This typically requires administrative privileges.
    - **Static Groups**: This script manages static group memberships exclusively and does not handle dynamic group rules or memberships.
    - **Security**: Store the App Secret and other sensitive information securely. Avoid hardcoding sensitive data directly within scripts.
    - **Modules**: The script automatically installs required Microsoft Graph modules if they are not already present on the system.

.EXAMPLE
    .\AzureAD-DeviceGroupManagement.ps1

.NOTES
    Author  : Mohammad Abdulkader Omar
    Website : momar.tech
    Date    : 2024-11-07
#>

# Parameters for batch processing and group management
Param (
    [int]$BatchSize = 500,
    [string]$GroupNamePrefix = "Devices-group",
    [int]$NamePadding = 2,  # Number of digits in group numbering
    [switch]$EnableLogging, # Enable logging to a file
    [string]$LogFilePath = "C:\CreateStaticGroup\GroupCreationLog.txt"
)

# Function to log messages with timestamps and color-coded output
Function Log-Message {
    param (
        [string]$Message,
        [string]$MessageType = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $formattedMessage = "[$timestamp] [$MessageType] $Message"

    switch ($MessageType) {
        "INFO" { Write-Host $formattedMessage -ForegroundColor Cyan }
        "SUCCESS" { Write-Host $formattedMessage -ForegroundColor Green }
        "WARNING" { Write-Host $formattedMessage -ForegroundColor Yellow }
        "ERROR" { Write-Host $formattedMessage -ForegroundColor Red }
        default { Write-Host $formattedMessage }
    }

    if ($EnableLogging) {
        # Ensure the log directory exists
        $logDir = Split-Path -Path $LogFilePath
        if (-not (Test-Path -Path $logDir)) {
            New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        }
        Add-Content -Path $LogFilePath -Value $formattedMessage
    }
}

# Connect to Microsoft Graph

# Install and Import Microsoft Graph Modules
Write-Host "Installing Microsoft Graph modules if required (current user scope)" -ForegroundColor Cyan

# Install Microsoft Graph Authentication Module if not installed
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Authentication)) {
    try {
        Install-Module -Name Microsoft.Graph.Authentication -Scope CurrentUser -Repository PSGallery -Force
        Write-Host "Microsoft Graph Authentication Module Installed Successfully" -ForegroundColor Green
    } catch {
        Write-Host "Failed to Install Microsoft Graph Authentication Module: $($_.Exception.Message)" -ForegroundColor Red
        exit
    }
} else {
    Write-Host "Microsoft Graph Authentication Module Already Installed" -ForegroundColor Green
}

# Install Microsoft.Graph.Beta.DeviceManagement.Actions if not installed
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Beta.DeviceManagement.Actions)) {
    try {
        Install-Module -Name Microsoft.Graph.Beta.DeviceManagement.Actions -Scope CurrentUser -Repository PSGallery -Force
        Write-Host "Microsoft Graph Beta Device Management Module Installed Successfully" -ForegroundColor Green
    } catch {
        Write-Host "Failed to Install Microsoft Graph Beta Device Management Module: $($_.Exception.Message)" -ForegroundColor Red
        exit
    }
} else {
    Write-Host "Microsoft Graph Beta Device Management Module Already Installed" -ForegroundColor Green
}

# Import necessary modules
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Beta.DeviceManagement.Actions

# Connect to Microsoft Graph
Connect-MgGraph

# Connect to Azure AD
Connect-AzureAD

# Function to determine the next group number based on existing groups
Function Get-NextGroupNumber {
    param (
        [array]$ExistingNames,
        [string]$Prefix,
        [int]$Padding
    )

    $pattern = "^$Prefix(\d{$Padding})$"
    $numbers = foreach ($name in $ExistingNames) {
        if ($name -match $pattern) {
            [int]$matches[1]
        }
    }

    if ($numbers.Count -eq 0) {
        return 1
    } else {
        return ($numbers | Measure-Object -Maximum).Maximum + 1
    }
}

# Function to create a new Azure AD group
Function Create-NewGroup {
    param (
        [string]$GroupName
    )

    try {
        $newGroup = New-AzureADGroup -DisplayName $GroupName `
                                     -MailEnabled $false `
                                     -SecurityEnabled $true `
                                     -MailNickname $GroupName `
                                     -Description "Static security group containing up to $BatchSize Windows devices."

        Log-Message "Created group: $GroupName (Id: $($newGroup.ObjectId))" -MessageType "SUCCESS"
        return $newGroup
    } catch {
        Log-Message "Failed to create group $GroupName : $_" -MessageType "ERROR"
        return $null
    }
}

# Function to add devices to an Azure AD group
Function Add-DevicesToGroup {
    param (
        [string]$GroupId,
        [array]$Devices,
        [string]$GroupName
    )

    try {
        Log-Message "Retrieving existing members of group '$GroupName'..." -MessageType "INFO"
        $existingMembers = Get-AzureADGroupMember -ObjectId $GroupId -All $true | Select-Object -ExpandProperty ObjectId
        $existingMemberSet = @{}
        foreach ($memberId in $existingMembers) {
            $existingMemberSet[$memberId] = $true
        }

        $devicesToAdd = $Devices | Where-Object { -not $existingMemberSet.ContainsKey($_.Id) }

        if ($devicesToAdd.Count -eq 0) {
            Log-Message "All devices in batch are already members of group '$GroupName'. Skipping." -MessageType "WARNING"
            return
        }

        Log-Message "Adding $($devicesToAdd.Count) devices to group '$GroupName'..." -MessageType "INFO"

        foreach ($device in $devicesToAdd) {
            try {
                Add-AzureADGroupMember -ObjectId $GroupId -RefObjectId $device.Id -ErrorAction Stop
                Log-Message "Added device '$($device.DisplayName)' (Id: $($device.Id)) to group '$GroupName'." -MessageType "SUCCESS"
            } catch {
                Log-Message "Failed to add device '$($device.DisplayName)' (Id: $($device.Id)) to group '$GroupName': $_" -MessageType "ERROR"
            }
        }

        Log-Message "Completed adding devices to group '$GroupName'." -MessageType "SUCCESS"
    } catch {
        Log-Message "Error processing group '$GroupName': $_" -MessageType "ERROR"
    }
}

# Main function to retrieve devices and assign them to groups
Function Get-DevicesAndAssignToGroups {
    Log-Message "Retrieving all Windows PC devices from Microsoft Graph..." -MessageType "INFO"
    try {
        $allDevices = Get-MgDevice -Filter "startswith(operatingSystem,'Windows')" -All
        if ($allDevices.Count -eq 0) {
            Log-Message "No Windows PC devices found. Exiting script." -MessageType "WARNING"
            return
        }
        Log-Message "Total devices retrieved: $($allDevices.Count)" -MessageType "INFO"
    } catch {
        Log-Message "Error retrieving devices: $_" -MessageType "ERROR"
        exit
    }

    Log-Message "Retrieving existing groups with prefix '$GroupNamePrefix'..." -MessageType "INFO"
    try {
        $existingGroups = Get-AzureADGroup -Filter "startswith(DisplayName,'$GroupNamePrefix')"
        $existingGroupNames = $existingGroups | Select-Object -ExpandProperty DisplayName
    } catch {
        Log-Message "Error retrieving existing groups: $_" -MessageType "ERROR"
        exit
    }

    $nextGroupNumber = Get-NextGroupNumber -ExistingNames $existingGroupNames -Prefix $GroupNamePrefix -Padding $NamePadding
    Log-Message "Next group number to create: $nextGroupNumber" -MessageType "INFO"

    # Split devices into batches based on BatchSize
    $deviceGroups = @()
    for ($i = 0; $i -lt $allDevices.Count; $i += $BatchSize) {
        $currentBatch = $allDevices[$i..([Math]::Min($i + $BatchSize - 1, $allDevices.Count - 1))]
        $deviceGroups += ,$currentBatch
    }

    # Iterate through each device group and assign to groups
    for ($groupIndex = 0; $groupIndex -lt $deviceGroups.Count; $groupIndex++) {
        $groupNumber = $groupIndex + 1
        $groupName = "{0}{1}" -f $GroupNamePrefix, ($groupNumber.ToString()).PadLeft($NamePadding, '0')

        $existingGroup = $existingGroups | Where-Object { $_.DisplayName -eq $groupName }

        if ($existingGroup) {
            Log-Message "Group '$groupName' already exists. Assigning devices to this group." -MessageType "INFO"
            Add-DevicesToGroup -GroupId $existingGroup.ObjectId -Devices $deviceGroups[$groupIndex] -GroupName $groupName
        } else {
            Log-Message "Group '$groupName' does not exist. Creating new group." -MessageType "INFO"
            $newGroup = Create-NewGroup -GroupName $groupName

            if ($newGroup) {
                Add-DevicesToGroup -GroupId $newGroup.ObjectId -Devices $deviceGroups[$groupIndex] -GroupName $groupName
            } else {
                Log-Message "Skipping device assignment for group '$groupName' due to creation failure." -MessageType "ERROR"
            }
        }

        Write-Host "--------------------------------------------------" -ForegroundColor DarkGray
    }

    Log-Message "All groups processed and devices assigned successfully." -MessageType "SUCCESS"
}

# Execute the main function
Get-DevicesAndAssignToGroups
