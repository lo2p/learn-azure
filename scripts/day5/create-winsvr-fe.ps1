#0. 공통
$location = "koreacentral"
$TimeZone ="Korea Standard Time"

#1. 리소스 그룹
$rg = Get-AzResourceGroup -Name "rg-hallofarmor" -Location $location

#2. 가상 네트워크
$vnet = Get-AzVirtualNetwork `
  -ResourceGroupName $rg.ResourceGroupName `
  -Name "vnet-hallofarmor-kc"

#3. 공용 IP 주소 만들기
$pip = New-AzPublicIpAddress `
  -ResourceGroupName $rg.ResourceGroupName `
  -Location $location `
  -AllocationMethod Static `
  -IdleTimeoutInMinutes 4 `
  -Name "pip-vmjarvisfe"

#4. 네트워크 보안 그룹
#4.1 포트 3389에 대한 인바운드 네트워크 보안 그룹 규칙 만들기
$nsgRuleRDP = New-AzNetworkSecurityRuleConfig `
-Name "RDP"  `
-Protocol "Tcp" `
-Direction "Inbound" `
-Priority 1000 `
-SourceAddressPrefix * `
-SourcePortRange * `
-DestinationAddressPrefix * `
-DestinationPortRange 3389 `
-Access "Allow"

#4.2 포트 80에 대한 인바운드 네트워크 보안 그룹 규칙 만들기
$nsgRuleWeb = New-AzNetworkSecurityRuleConfig `
-Name "WWW"  `
-Protocol "Tcp" `
-Direction "Inbound" `
-Priority 1001 `
-SourceAddressPrefix * `
-SourcePortRange * `
-DestinationAddressPrefix * `
-DestinationPortRange 80 `
-Access "Allow"

#4.3 네트워크 보안 그룹 만들기
$nsg = New-AzNetworkSecurityGroup `
-ResourceGroupName $rg.ResourceGroupName `
-Location $location `
-Name "nsg-vmjarvisfe" `
-SecurityRules $nsgRuleRDP,$nsgRuleWeb

#5. 공용 IP 주소와 NSG가 연결된 가상 네트워크 카드 만들기
$nic = New-AzNetworkInterface `
  -Name "nic-01-vmjarvisfe" `
  -ResourceGroupName $rg.ResourceGroupName `
  -Location $location `
  -SubnetId $vnet.Subnets[0].Id `
  -PublicIpAddressId $pip.Id `
  -NetworkSecurityGroupId $nsg.Id
  
#6. 가상 머신 구성 
#6.1 자격증명 객체 정의
$securePassword = ConvertTo-SecureString 'Pa55w.rdKTAz' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("tony", $securePassword)

#6.2 가상 머신 구성 만들기
$vmConfig = New-AzVMConfig `
  -VMName "vmjarvisfe" `
  -VMSize "Standard_B2ms" | `
Set-AzVMOperatingSystem `
  -Windows `
  -ComputerName "vmjarvisfe" `
  -Credential $cred `
  -TimeZone $TimeZone | `
Set-AzVMSourceImage `
  -PublisherName "MicrosoftWindowsServer" `
  -Offer "WindowsServer" `
  -Skus "2019-Datacenter" `
  -Version "latest" | `
Add-AzVMNetworkInterface `
  -Id $nic.Id | `
Set-AzVMBootDiagnostic -Disable

#4. VM 배포
New-AzVM `
  -ResourceGroupName $rg.ResourceGroupName `
  -Location $location -VM $vmConfig

#5. VM 공용 IP 확인
#$PubIp = (Get-AzPublicIpAddress -Name pip-vmjarvisfe).IpAddress   

#6. VM SSH 연결
#mstsc /v:$PubIp

#7. IIS 설치 및 샘플 페이지 생성
#Install-WindowsFeature -Name Web-Server -IncludeManagementTools
#Set-Content -Path "C:\inetpub\wwwroot\Default.htm" -Value "Running JARVIS Web Service from host $($env:computername) !"