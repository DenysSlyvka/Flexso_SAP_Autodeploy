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
    $hostname = Read-Host -Prompt 'Enter hostname of the virtual machine [default: "myvm"]'
    $sid = Read-Host -Prompt 'Enter SID for HDB server'
    $instancenr = Read-Host -Prompt 'Enter instance number for HDB server'

    Add-Content $Path\external_vars.yml "hostname: $hostname"
    Add-Content $Path\external_vars.yml "sid: $sid"
    Add-Content $Path\external_vars.yml "instancenr: $instancenr"

    cd $path
    terraform init
    terraform plan -out sap-terraformplan.tfplan -var="hostname=$hostname"
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

                $path = '..\Flexso_SAP_Autodeploy\Azure\AzureSAPDeploy\terraform'
                Input-Params-HDB -Path $path

            } '2' {
                echo "Hana express on Azure example"
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

