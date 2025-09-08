#0. 공통
$location = "koreacentral"
$TimeZone ="Korea Standard Time"

#1. 리소스 그룹
$rg = New-AzResourceGroup -Name "rg-hybrid" -Location $location

#2. 가상 네트워크
$virtualNetwork = @{
  Name = 'vnet-hybrid-kr'
  ResourceGroupName = $rg.ResourceGroupName
  Location = $location
  AddressPrefix = '10.1.0.0/16'    
}
$vnet = New-AzVirtualNetwork @virtualNetwork

$subnet = @{
  Name = 'snet-dev'
  VirtualNetwork = $vnet
  AddressPrefix = '10.1.0.0/24'
}
Add-AzVirtualNetworkSubnetConfig @subnet

$vnet | Set-AzVirtualNetwork

$vnet = Get-AzVirtualNetwork `
  -ResourceGroupName $rg.ResourceGroupName `
  -Name "vnet-hybrid-kr"

#3. 공용 IP 주소 만들기
$pip = New-AzPublicIpAddress `
  -ResourceGroupName $rg.ResourceGroupName `
  -Location $location `
  -AllocationMethod Static `
  -IdleTimeoutInMinutes 4 `
  -Name "pip-vmwin11dev"

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

#4.2 네트워크 보안 그룹 만들기
$nsg = New-AzNetworkSecurityGroup `
-ResourceGroupName $rg.ResourceGroupName `
-Location $location `
-Name "nsg-vmwin11dev" `
-SecurityRules $nsgRuleRDP

#5. 공용 IP 주소와 NSG가 연결된 가상 네트워크 카드 만들기
$nic = New-AzNetworkInterface `
  -Name "nic-01-vmwin11dev" `
  -ResourceGroupName $rg.ResourceGroupName `
  -Location $location `
  -SubnetId $vnet.Subnets[0].Id `
  -PublicIpAddressId $pip.Id `
  -NetworkSecurityGroupId $nsg.Id
  
#6. 가상 머신 구성 
#6.1 자격증명 객체 정의
$securePassword = ConvertTo-SecureString 'Pa55w.rdBSAz' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("tony", $securePassword)

#6.2 가상 머신 구성 만들기
$vmConfig = New-AzVMConfig `
  -VMName "vmwin11dev" `
  -VMSize "Standard_D4s_v3" | `
Set-AzVMOperatingSystem `
  -Windows `
  -ComputerName "vmwin11dev" `
  -Credential $cred `
  -TimeZone $TimeZone | `
Set-AzVMSourceImage `
  -PublisherName "MicrosoftWindowsDesktop" `
  -Offer "Windows-11" `
  -Skus "win11-24h2-pro" `
  -Version "latest" | `
Add-AzVMNetworkInterface `
  -Id $nic.Id | `
Set-AzVMBootDiagnostic -Disable

#4. VM 배포
New-AzVM `
  -ResourceGroupName $rg.ResourceGroupName `
  -Location $location -VM $vmConfig
