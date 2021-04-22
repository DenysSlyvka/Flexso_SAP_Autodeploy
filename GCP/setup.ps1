function Show-Menu
{
    param (
        [string]$Title = 'Choose setup'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: SAP HANA Database + NetWeaver ABAP"
    Write-Host "2: SAP HANA Express (test)"
    #Write-Host "3: Press '3' for this option."
    Write-Host "Q: Press 'Q' to quit."
}

Show-Menu –Title 'Choose setup'
 $selection = Read-Host "Please make a selection"
 switch ($selection)
 {
     '1' {
     
     $exampleFile = @"
#this file contains input variables for hana
---
"@
    $exampleFile | Out-File -Encoding utf8 ..\GCP\SAP-HANA-NETWEAVER-ABAP\terraform\external_vars.yml # C:\Users\Dirk\Documents\GitHub\Flexso_SAP_Autodeploy\GCP

    $hostname = Read-Host -Prompt 'Enter hostname of the virtual machine [default: "myvm"]'
    $sid = Read-Host -Prompt 'Enter SID for HDB server'
    $instancenr = Read-Host -Prompt 'Enter instance number for HDB server'

    Add-Content ..\GCP\SAP-HANA-NETWEAVER-ABAP\terraform\external_vars.yml "hostname: $hostname"
    Add-Content ..\GCP\SAP-HANA-NETWEAVER-ABAP\terraform\external_vars.yml "sid: $sid"
    Add-Content ..\GCP\SAP-HANA-NETWEAVER-ABAP\terraform\external_vars.yml "instancenr: $instancenr"
    cd C:\Users\Dirk\Documents\GitHub\Flexso_SAP_Autodeploy\GCP\SAP-HANA-NETWEAVER-ABAP\terraform
    terraform init
    terraform plan -out sap-hana-express-terraformplan.tfplan
    terraform apply sap-hana-express-terraformplan.tfplan

     } '2' {

    $exampleFile = @"
#this file contains input variables for hana
---
"@
    $exampleFile | Out-File -Encoding utf8 ..\GCP\SAP-HANA-EXPRESS\terraform\external_vars.yml # C:\Users\Dirk\Documents\GitHub\Flexso_SAP_Autodeploy\GCP

    $hostname = Read-Host -Prompt 'Enter hostname of the virtual machine [default: "myvm"]'
    $sid = Read-Host -Prompt 'Enter SID for HDB server'
    $instancenr = Read-Host -Prompt 'Enter instance number for HDB server'

    Add-Content ..\GCP\SAP-HANA-EXPRESS\terraform\external_vars.yml "hostname: $hostname"
    Add-Content ..\GCP\SAP-HANA-EXPRESS\terraform\external_vars.yml "sid: $sid"
    Add-Content ..\GCP\SAP-HANA-EXPRESS\terraform\external_vars.yml "instancenr: $instancenr"
     } 'q' {
         return
     }
 }