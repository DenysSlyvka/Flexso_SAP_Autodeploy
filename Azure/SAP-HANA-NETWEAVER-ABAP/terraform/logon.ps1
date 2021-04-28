sshkey=C:/ssh_keys/sshkey.pem
ipaddress=$(<C:/ssh_keys/publicIP.txt)
ssh -i $sshkey azureuser@"$ipaddress"
