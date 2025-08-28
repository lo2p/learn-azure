# IIS(웹서버) 설치
Install-WindowsFeature -Name Web-Server -IncludemanagementTools
# Default.htm 파일수정
Set-Content -Path "C:\inetPub\wwwroot\Default.htm" -Value "Running JARVIS 2.0 Web Service from host $($env:computername) !"