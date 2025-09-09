#IIS 설치
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

#Default.html 만들기
Set-Content -Path "C:\inetpub\wwwroot\Default.htm" -Value "Azure Arc enabled Windows Server from host $($env:computername) !"
