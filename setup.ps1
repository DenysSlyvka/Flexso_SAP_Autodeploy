function Show-Menu-Setup-GCP
{
    param (
        [string]$Title = 'Title'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host "1: SAP HANA Database + NetWeaver ABAP"
    Write-Host "2: SAP HANA Express (test)"
    Write-Host "3: SAP HANA Database + ABAP Foundation"
    Write-Host "Q: Press 'Q' to quit."
}

function Show-Menu-Setup-Azure
{
    param (
        [string]$Title = 'Title'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host "1: SAP HANA Database + NetWeaver ABAP"
    Write-Host "2: SAP HANA Express (test)"
    Write-Host "3: SAP JAVA ASE"
    Write-Host "Q: Press 'Q' to quit."
}

function Show-Menu-Platform
{
    param (
        [string]$Title = 'Title'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host "1: Azure"
    Write-Host "2: Google Cloud"
    Write-Host "Q: Press 'Q' to quit."
}

<#
This function handles the user input for the HANA Database variables
This function is called whenever the user selects an option that includes installing HANA database
Currently this function is used at:
Azure -> SAP-HANA-NETWEAVER-ABAP 
GCP -> SAP-HANA-NETWEAVER-ABAP
GCP -> SAP-HANA-ABAP-FOUNDATION
#>

function Deploy-HANA-EXPRESS
{
    param (
        [string]$Path = ''
    )

    $resourcegroupname = Read-Host -Prompt 'Enter resource group name [default: Azure_SAP_Automatic_Install]'

    cd $Path
    terraform init
    terraform plan -out sap-terraformplan.tfplan -var="resourcegroupname=$resourcegroupname"
    terraform apply sap-terraformplan.tfplan
}
function Input-Params-HDB
{
    param (
        [string]$Path = ''
    )
    $exampleFile = @"
#this file contains input variables for hana
---
"@
    $exampleFile | Out-File -Encoding utf8 $path\external_vars.yml # C:\Users\Dirk\Documents\GitHub\Flexso_SAP_Autodeploy\GCP
    $resourcegroupname = Read-Host -Prompt 'Enter resource group name [default: Azure_SAP_Automatic_Install]'
    $hostname = Read-Host -Prompt 'Enter hostname of the virtual machine [default: myvm]'
    $sid = Read-Host -Prompt 'Enter SID for HDB server'
    $instancenr = Read-Host -Prompt 'Enter instance number for HDB server'
    $nwsid = Read-Host -Prompt 'Enter the SID for NetWeaver [Must be different from the SID for HDB]'
    $ascsinstancenr = Read-Host -Prompt 'Enter the ASCS instance number for Netweaver [default: 01]'
    $primaryinstancenr = Read-Host -Prompt 'Enter the instance number for the primary application server [default: 00]'

    Add-Content $Path\external_vars.yml "hostname: $hostname"
    Add-Content $Path\external_vars.yml "sid: $sid"
    Add-Content $Path\external_vars.yml "instancenr: '$instancenr'"
    Add-Content $Path\external_vars.yml "nwsid: $nwsid"
    Add-Content $Path\external_vars.yml "ascsinstancenr: '$ascsinstancenr'"
    Add-Content $Path\external_vars.yml "primaryinstancenr: '$primaryinstancenr'"

    cd $path
    terraform init
    terraform plan -out sap-terraformplan.tfplan -var="hostname=$hostname" -var="resourcegroupname=$resourcegroupname"
    terraform apply sap-terraformplan.tfplan
}

function Input-Params-JAVA
{
    param (
        [string]$Path = ''
    )
    $exampleFile = @"
#this file contains input variables for hana
---
"@
    $exampleFile | Out-File -Encoding utf8 $path\external_vars.yml # C:\Users\Dirk\Documents\GitHub\Flexso_SAP_Autodeploy\GCP
    $resourcegroupname = Read-Host -Prompt 'Enter resource group name [default: Azure_SAP_Automatic_Install]'
    $hostname = Read-Host -Prompt 'Enter hostname of the virtual machine [default: myvm]'
    $nwsid = Read-Host -Prompt 'Enter the SID for JAVA [Must be different from the SID for HDB]'
    $ascsinstancenr = Read-Host -Prompt 'Enter the SCS instance number for JAVA [default: 01]'
    $primaryinstancenr = Read-Host -Prompt 'Enter the instance number for the primary application server [default: 00]'

    Add-Content $Path\external_vars.yml "hostname: $hostname"
    Add-Content $Path\external_vars.yml "nwsid: $nwsid"
    Add-Content $Path\external_vars.yml "ascsinstancenr: '$ascsinstancenr'"
    Add-Content $Path\external_vars.yml "primaryinstancenr: '$primaryinstancenr'"

    cd $path
    terraform init
    terraform plan -out sap-terraformplan.tfplan -var="hostname=$hostname" -var="resourcegroupname=$resourcegroupname"
    terraform apply sap-terraformplan.tfplan
}

Show-Menu-Platform –Title 'Choose platform'
 $platform = Read-Host "Please choose a platform"
 switch ($platform)
 {
    '1' { #This contains a switch statement for every option available on the platform 'Azure'
         Show-Menu-Setup-Azure -Title 'Choose a setup for Azure'
         $selection = Read-Host "Please make a selection"
         switch ($selection)
         {
            '1' {

                $path = '..\Flexso_SAP_Autodeploy\Azure\SAP-HANA-NETWEAVER-ABAP\terraform'
                Input-Params-HDB -Path $path

            } '2' {
                $path = '..\Flexso_SAP_Autodeploy\Azure\SAP-HANA-EXPRESS\terraform'
                Deploy-HANA-EXPRESS -Path $path

            } '3' {
                
                $path = '..\Flexso_SAP_Autodeploy\Azure\SAP-ASE-JAVA\terraform'
                Input-Params-JAVA -Path $path
              
             } 'q' {
                 return
             } 
         }
    } '2' { #This contains a switch statement for every option available on the platform 'Google Cloud'
         Show-Menu-Setup-GCP –Title 'Choose setup for Google Cloud'
         $selection = Read-Host "Please make a selection"
         switch ($selection)
         {
             '1' {

                $path = '..\Flexso_SAP_Autodeploy\GCP\SAP-HANA-NETWEAVER-ABAP\terraform'
                Input-Params-HDB -Path $path

             } '2' {
                echo "Hana express on GCP example"
             } '3' {
                
                $path = '..\Flexso_SAP_Autodeploy\GCP\SAP-HANA-ABAP-FOUNDATION\terraform'
                Input-Params-HDB -Path $path
              
             } 'q' {
                 return
             }
         }
    }
 }

