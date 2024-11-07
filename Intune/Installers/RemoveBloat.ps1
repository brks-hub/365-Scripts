# Variables for registered app credentials
$ClientID = Read-Host -Prompt "Enter your Client ID"
$TenantID = Read-Host -Prompt "Enter your Tenant ID"
$ClientSecret = Read-Host -Prompt "Enter your Client Secret" -AsSecureString

# Connect to Microsoft Graph using client credentials
$ClientSecretPlainText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($ClientSecret))
Connect-MSIntuneGraph -ClientId $ClientID -TenantId $TenantID -ClientSecret $ClientSecretPlainText

# Create working directory
$appfolder = New-Item -Path ".\" -Name "RemoveBloat" -ItemType Directory -Force
$downloadsource = 'https://raw.githubusercontent.com/brks-hub/365-Scripts/main/RemoveBloat.exe'
$filename = "RemoveBloat.exe"
$downloaddestination = $appfolder
Start-BitsTransfer -Source $downloadsource -Destination "$downloaddestination\$filename"

# Create the intunewin file and assign path
$Source = $appfolder
$SetupFile = $filename
$Destination = $appfolder
$CreateAppPackage = New-IntuneWin32AppPackage -SourceFolder $Source -SetupFile $SetupFile -OutputFolder $Destination -ErrorAction Ignore -Verbose -Force
$IntuneWinFile = $CreateAppPackage.Path

# Set app metadata
$Displayname = "RemoveBloat"
$Description = "RemoveBloat Tool"
$Publisher = "RemoveBloat Inc."

# Detection Rule for Intune
$DetectionRule = New-IntuneWin32AppDetectionRuleFile -Existence -FileOrFolder RemoveBloat.exe -Path "C:\RemoveBloat\" -Check32BitOn64System $false -DetectionType "exists"

# Requirement Rule
$RequirementRule = New-IntuneWin32AppRequirementRule -Architecture "x64" -MinimumSupportedOperatingSystem "W10_21H2"

# Install and Uninstall Commands - The uninstall command has a placeholder since none is specified
$InstallCommandLine = "$filename /silent"
$UninstallCommandLine = "cmd /c echo No Uninstall Command"

# Upload the package to Intune
Add-IntuneWin32App -FilePath $IntuneWinFile -DisplayName $Displayname -Description $Description -Publisher $Publisher -InstallExperience "system" -RestartBehavior "suppress" -DetectionRule $DetectionRule -RequirementRule $RequirementRule -InstallCommandLine $InstallCommandLine -UninstallCommandLine $UninstallCommandLine -Verbose
