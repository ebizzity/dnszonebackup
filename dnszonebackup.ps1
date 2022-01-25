$subid = "<xxxxxx>"    #Subscription Id where zones are
$rgname = "<RG_NAME>"      #Resource Group where zones are
$storageacctName = "<STGACCTName>"      #Storage Account Name
$blobcontainerName = "backups"           #Blob container name
$storageacctRG = "<STG_RG_NAME>"           #Storage Account Resource Group

#Login
Login-AzAccount -Identity

#Set Subscription
Set-AzContext -SubscriptionId $subid

#Create Temp Folder
mkdir dnsbackup


#Get Zones
$zones = Get-AzPrivateDnsZone -ResourceGroupName $rgname

#Backup Zones
foreach ($zone in $zones){
    Export-AzResourceGroup -ResourceGroupName $rgname -IncludeParameterDefaultValue -Resource $($zone).ResourceId -Path .\dnsbackup\$($zone.Name).json -Force
}

#Get Storage Account Context

$ctx =  New-AzStorageContext -StorageAccountName $storageacctName -UseConnectedAccount 

#Upload backups to blob container

ls .\dnsbackup -File -Recurse | Set-AzStorageBlobContent -Container $blobcontainerName -Context $ctx -Force

#Cleanup temp folder
Remove-Item -Path .\dnsbackup -Recurse

