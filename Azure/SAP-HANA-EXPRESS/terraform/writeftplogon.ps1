###########################################################
#
#	This script requires the Posh-SSH module.
#	It can be installed with the following command:
Install-Module -Name Posh-SSH
#
#	Set values for the following variables:
#
#	Enter the username below
$username= "flexsostageadmin"
#
#	Generate the $encrypted value with the following commands:
#$secure = Read-Host -AsSecureString
#	<Enter in the password>
#$encrypted = ConvertFrom-SecureString -SecureString $secure
#	$encrypted
#	<Copy the value which is displayed, and paste it in as the value below>
#$encrypted = "01000000d08c9ddf0115d00000001000000010000003abd0970300000001000000010000000002000000000003660000c000000010000000972fa750140c0b1d2f0b3701ff3559c70000000004800000a00000001000000050000000100000001000000083d3b231a48b71800000019000000010000000100000001000000010000000100000000694b87b9d000000010000000120f2abc373"
#
#	Enter the IP for the SFTP server
$serverIP = "51.103.26.163"
#
#	Enter the file Locations
$local = "C:\ssh_keys\publicIP.txt"
$remote = "/home/flexsostageadmin/ftp/HANA-EXPRESS/SSHCONNECTION/"
#
###########################################################

$password = "Flexsostageadmin2020"

$credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $username, $password

$session = New-SFTPSession -ComputerName $serverIP -Credential $credential -AcceptKey

$setParams = @{
    SessionId = $session.SessionId
    LocalFile = $local
   RemotePath = $remote
}

Set-SFTPFile @setParams

if ($session = Get-SFTPSession -SessionId $session.SessionId) {
    $session.Disconnect()
}

$null = Remove-SftpSession -SftpSession $session




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