

#Setup IIS
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

#Create Default.html
Set-Content -Path "C:\inetpub\wwwroot\Default.htm" -Value "Running FRIDAY Web Service from host $($env:computername) !"
