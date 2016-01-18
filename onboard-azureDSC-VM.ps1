# log in to both Azure Service Management and Azure Resource Manager
Add-AzureAccount
Login-AzureRmAccount

# fill in correct values for your VM / Automation Account here
$VMName = ""
$ServiceName = ""
$AutomationAccountName = ""
$AutomationAccountResourceGroup = ""

# fill in the name of a Node Configuration in Azure Automation DSC, for this VM to conform to
$NodeConfigName = ""

# get Azure Automation DSC registration info
$Account = Get-AzureRmAutomationAccount -ResourceGroupName $AutomationAccountResourceGroup -Name $AutomationAccountName
$RegistrationInfo = $Account | Get-AzureRmAutomationRegistrationInfo

# use the DSC extension to onboard the VM for management with Azure Automation DSC
$VM = Get-AzureVM -Name $VMName -ServiceName $ServiceName

$PublicConfiguration = ConvertTo-Json -Depth 8 @{
  SasToken = ""
  ModulesUrl = "https://eus2oaasibizamarketprod1.blob.core.windows.net/automationdscpreview/RegistrationMetaConfigV2.zip"
  ConfigurationFunction = "RegistrationMetaConfigV2.ps1\RegistrationMetaConfigV2"

# update these DSC agent Local Configuration Manager defaults if they do not match your use case.
# See https://technet.microsoft.com/library/dn249922.aspx?f=255&MSPPError=-2147217396 for more details
Properties = @{
   RegistrationKey = @{
     UserName = 'notused'
     Password = 'PrivateSettingsRef:RegistrationKey'
}
  RegistrationUrl = $RegistrationInfo.Endpoint
  NodeConfigurationName = $NodeConfigName
  ConfigurationMode = "ApplyAndMonitor"
  ConfigurationModeFrequencyMins = 15
  RefreshFrequencyMins = 30
  RebootNodeIfNeeded = $False
  ActionAfterReboot = "ContinueConfiguration"
  AllowModuleOverwrite = $False
  }
}

$PrivateConfiguration = ConvertTo-Json -Depth 8 @{
  Items = @{
     RegistrationKey = $RegistrationInfo.PrimaryKey
  }
}

$VM = Set-AzureVMExtension `
 -VM $vm `
 -Publisher Microsoft.Powershell `
 -ExtensionName DSC `
 -Version 2.6 `
 -PublicConfiguration $PublicConfiguration `
 -PrivateConfiguration $PrivateConfiguration `
 -ForceUpdate

$VM | Update-AzureVM