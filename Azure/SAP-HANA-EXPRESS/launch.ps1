$selection = Read-Host "Please type Confirm"
cd C:\Users\Dirk\Documents\GitHub\Flexso_SAP_Autodeploy\Azure\SAP-HANA-EXPRESS
terraform init
terraform plan -out sap-hana-express-terraformplan.tfplan
terraform apply sap-hana-express-terraformplan.tfplan