#1. Azure PowerShell 설치
Install-module -Name Az -AllowClobber

#2. Azure 연결
Connect-AzAccount

#3. Azure 구독 확인
Get-AzSubscription

#4. Azure 구독 선택
Select-AzSubscription -Subscription (Get-AzSubscription).Id

#5. 리소스 공급자 확인
Get-AzResourceProvider -ProviderNamespace Microsoft.DataMigration

#6. 리소스 공급자 등록
Register-AzResourceProvider -ProviderNamespace Microsoft.DataMigration