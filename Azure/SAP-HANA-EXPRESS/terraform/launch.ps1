﻿$selection = Read-Host "Please type Confirm"
cd C:\Users\Dirk\Documents\GitHub\Flexso_SAP_Autodeploy\Azure\SAP-HANA-EXPRESS\terraform
terraform init
terraform plan -out sap-hana-express-terraformplan.tfplan
terraform apply sap-hana-express-terraformplan.tfplan


sshkey=C:/ssh_keys/sshkey.pem
ipaddress=$(<C:/ssh_keys/publicIP.txt)
ssh -i $sshkey azureuser@"$ipaddress"


$sftpHost = "51.103.26.163"

$port = "22"

$userName = "flexsostageadmin"

$userPassword = "Flexsostageadmin2020"

$files = "C:/ssh_keys/publicIP.txt", "C:/ssh_keys/sshkey.pem" #specify full path to  your files here

$sftp = Open-SFTPServer -serverAddress $sftpHost -userName $userName -userPassword $userPassword
foreach($file in $files){

$sftp.Put($file, "/home/flexsostageadmin/ftp/HANA-EXPRESS/SSHCONNECTION")
}

#Close the SFTP connection

$sftp.Close()
