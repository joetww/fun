if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

Get-NetAdapter | SELECT Name, ifIndex, Status | where status -eq 'up' | ForEach-Object {
	echo $_.Name
	Set-DnsClientServerAddress -InterfaceIndex $_.ifIndex -ServerAddresses("192.168.99.6", "192.168.99.10", "8.8.8.8", "101.101.101.101")
}
