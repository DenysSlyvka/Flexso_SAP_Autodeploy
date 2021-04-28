

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



# //In de pipeline, zijn de gegevens van de login 
# //Moet in ansbile toegevoegd worden
# /*
# yum install -y ftp
# sftp flexsostageadmin@51.103.26.163
# cd ftp
# lcd /home/azureuser/Downloads
# get HXEDownloadManager_linux.bin



# Username: 	flexsostageadmin
# Pass:		Flexsostageadmin2020
# */