### Geruikte commando’s

Installatie Rar voor unzip van ABAP FND
wget -P /tmp https://www.rarlab.com/rar/rarlinux-x64-5.6.0.tar.gz

tar -zxvf /tmp/rarlinux-x64-5.6.0.tar.gz

/usr/local/bin/rar/unrar x /SAP/NetWeaver/NetWeaver/51052160_part2.rar
/usr/local/bin/rar/unrar x /SAP/NetWeaver/NetWeaver/51052161_part2.rar


# Commando voor installatie van ABAP 1709
./sapinst SAPINST_INPUT_PARAMETERS_URL=/SAP/SWMP/abapparam.params SAPINST_EXECUTE_PRODUCT_ID=NW_ABAP_OneHost:S4HANA1709.FNDN.HDB.ABAP SAPST_SKIP_DIALOGS=true SAPINST_START_GUISERVER=false


# Ruime toevoegen aan TMP map van 10 GB om de installatie mogelijk te maken
sudo mount -t tmpfs -o size=10737418240,mode=1777 overflow /tmp

sudo mount -t tmpfs -o size=80000000000,mode=1777 overflow /usr


### Full HANA DB | NW | ABAP install
yum update

vgextend /dev/rootvg /dev/sdc
lvextend -l +75%FREE /dev/rootvg/rootlv
lvextend -l +5%FREE /dev/rootvg/tmplv
lvextend -l +20%FREE /dev/rootvg/usrlv

xfs_growfs -d /
xfs_growfs -d /tmp
xfs_growfs -d /usr
cd /

subscription-manager repos --enable ansible-2.8-for-rhel-8-x86_64-rpms
yum install ansible -y
yum install git -y
yum install rsync -y
yum install sshpass -y
yum install libatomic -y
yum install libtool-ltdl -y


sshpass -p 'Flexsostageadmin2020' rsync -e "ssh -o StrictHostKeyChecking=no" -alPvz flexsostageadmin@51.103.26.163:/home/flexsostageadmin/ftp/HANA-PLATFORM/compat-sap-c++-9-9.1.1-2.3.el7_6.x86_64.rpm /SAP/HDB
rpm install /SAP/HDB/compat-sap-c++-9-9.1.1-2.3.el7_6.x86_64.rpm



git clone https://github.com/DenysSlyvka/Flexso_SAP_Autodeploy.git
ansible-playbook Flexso_SAP_Autodeploy/Azure/SAP-S4HANA/ansible/site.yml

# OPhalen van kernel files voor ABAP
sftp flexsostageadmin@51.103.26.163:/home/flexsostageadmin/ftp/SAPEXEDB_800-80002572.SAR /SAP/NetWeaver

 sftp flexsostageadmin@51.103.26.163:/home/flexsostageadmin/ftp/SAPEXE_800-80002573.SAR /SAP/NetWeaver


# JAVA Install
## Unrar JAVA software
/usr/local/bin/rar/unrar x /SAP/NW_JAVA/51050829_JAVA_part2.rar

## Untar ASE DB software


