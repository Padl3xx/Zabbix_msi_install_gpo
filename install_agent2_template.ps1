##This script is used to install and update zabbix agent version 2 via GPO
#
##Author: https://github.com/Padl3xx
#
##The script starts the GPO when the computer starts, it is applied to computers, not users.
##Create a new GPO, go to, Computer Configuration -> Policies -> Windows Settings -> Scripts -> Startup -> Powershell Scripts -> Add.
##Dont forget to link the GPO on specified OU :-)
##It should probably work if you run the installation directly from your computer, but I haven't tried that.
#
# Construct the FQDN (Fully Qualified Domain Name) of the local computer
$FQDN=(Get-WmiObject win32_computersystem).DNSHostName+"."+(Get-WmiObject win32_computersystem).Domain


#User-configurable variables
$ZabbixInstallationMSI = "\\yourdomain.com\NETLOGON\ZabbixAgent2\zabbix_agent2-7.0.9-windows-amd64-openssl.msi"
$ZabbixAgentVersion = "7.0.9"
$ZabbixServerIP = "8.8.8.8"
$ConfigFile = "C:\Program Files\Zabbix Agent 2\zabbix_agent2.conf"
#$ZabbixInstallationFolder = "\\$FQDN\c$\Program Files\Zabbix Agent 2\"
#$ZabbixPluginFolder = "\\yourdomain.com\NETLOGON\ZabbixAgent2\zabbix_agent2.d\"
#$ZabbixScriptsFolder = "\\yourdomain.com\NETLOGON\ZabbixAgent2\scripts"

# Be careful what you change here

if (get-service -Name "Zabbix Agent2") { 
Stop-Service -Name "Zabbix Agent2" -Force
sc.exe stop "Zabbix Agent2"
Start-Sleep -s 1
Remove-Item C:\Zabbix -Recurse -Force
sc.exe delete "Zabbix Agent2"
}

$ZabbixSoftwareName = "Zabbix Agent 2 (64-bit)"
$InstalledZabbixVersion = (Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq $ZabbixSoftwareName }).Version

# Extract the major version from the installed version
$InstalledVersion = $InstalledZabbixVersion -replace "(\d+\.\d+\.\d+).*", '$1'

$Arguments = "SERVER=$ZabbixServerIP HOSTMETADATA=Windows HOSTNAME=$FQDN LOGFILESIZE=20 DEBUGLEVEL=3 /qn"

if ([System.Version]$InstalledVersion -lt [System.Version]$ZabbixAgentVersion) {
    # The installed version is different from the desired version, so perform the installation or update

    if (Test-Path $ZabbixInstallationMSI) {
        # The installation file is available, so start the installation process
		Start-Process -FilePath "$ZabbixInstallationMSI" -ArgumentList "$Arguments" -Wait
	Start-Sleep -s 1	
	#if (Test-Path $ConfigFile) {
	#(Get-Content $ConfigFile) -replace '^(#?\s*LogFileSize=.*)', 'LogFileSize=20' |
    #ForEach-Object {$_ -replace '^(#?\s*DebugLevel=.*)', 'DebugLevel=3'} |
    #ForEach-Object {$_ -replace '^(ServerActive=.*)', '#ServerActive='} |
    #Set-Content $ConfigFile -Force
	#} else {
    #"[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Error: File $ConfigFile does not exist!" | Set-Content $FailLog -Force
	#}
		#Copy-Item -Path @($ZabbixPluginFolder, $ZabbixScriptsFolder) -Destination $ZabbixInstallationFolder -Force -Recurse
    } else {
        # The installation file is not available, exit the script
        exit
    }

}
## Function to update plugin and scripts folders if changes are detected
#if (!(Test-Path -Path "$ZabbixInstallationFolder\zabbix_agent2.d" -PathType Container)) {
##if not exist, folder is created
#    New-Item -ItemType Directory -Path "$ZabbixInstallationFolder\zabbix_agent2.d" -Force
#}
#
#if (!(Test-Path -Path "$ZabbixInstallationFolder\scripts" -PathType Container)) {
##if not exist, folder is created
#    New-Item -ItemType Directory -Path "$ZabbixInstallationFolder\scripts" -Force
#}
#
## Function to synchronize files of specified folders
#function Sync-Folder {
#    param(
#        [string]$sourceFolder,
#        [string]$destinationFolder
#    )
#    
#    $sourceFiles = Get-ChildItem -Path $sourceFolder -File
#    foreach ($file in $sourceFiles) {
#        $destinationFile = Join-Path -Path $destinationFolder -ChildPath $file.Name
#        if (!(Test-Path -Path $destinationFile -PathType Leaf)) {
#            #sync
#            Copy-Item -Path $file.FullName -Destination $destinationFolder
#        }
#    }
#}
#
## Sync files from given folders
#Sync-Folder -sourceFolder $ZabbixPluginFolder -destinationFolder "$ZabbixInstallationFolder\zabbix_agent2.d\"
#Sync-Folder -sourceFolder $ZabbixScriptsFolder -destinationFolder "$ZabbixInstallationFolder\scripts\"




