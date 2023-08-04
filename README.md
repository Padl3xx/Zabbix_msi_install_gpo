# Zabbix_msi_install_gpo
#Finally a easy way how to mass-deploy zabbix agent via GPO
#
##This script is used to install and update zabbix agent version 2 via GPO
#
##The script starts the GPO when the computer starts, it is applied to computers, not users.
##Create a new GPO, go to, Computer Configuration -> Policies -> Windows Settings -> Scripts -> Startup -> Powershell Scripts -> Add.
##Dont forget to link the GPO on specified OU :-)
##It should probably work if you run the installation directly from your computer, but I haven't tried that.
