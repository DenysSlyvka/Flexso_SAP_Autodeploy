
terraform init
terraform plan -out sap-hana-express-terraformplan.tfplan
terraform apply sap-hana-express-terraformplan.tfplan


sshkey=C:/ssh_keys/sshkey.pem
ipaddress=$(<C:/ssh_keys/publicIP.txt)
ssh -i $sshkey azureuser@"$ipaddress"



