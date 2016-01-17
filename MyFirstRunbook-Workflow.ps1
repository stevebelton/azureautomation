workflow MyFirstRunbook-Workflow
{
	Param (
		[string]$VMName,
		[string]$ResourceGroup
	)
	$credential = Get-AutomationPSCredential -Name 'AzureAdmin'
	Add-AzureRmAccount -Credential $credential
	stop-azurermvm -Name $VMName -resourcegroup $ResourceGroup -force
}