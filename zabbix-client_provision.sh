#!/bin/bash
TOMCAT=apache-tomcat-7.0.88
TOMCAT_WEBAPPS=$TOMCAT/webapps
TOMCAT_CONFIG=$TOMCAT/conf/server.xml
TOMCAT_START=$TOMCAT/bin/startup.sh
TOMCAT_ARCHIVE=$TOMCAT.tar.gz
TOMCAT_URL=http://ftp.byfly.by/pub/apache.org/tomcat/tomcat-7/v7.0.88/bin/$TOMCAT_ARCHIVE

# Installing java and tomcat
if [ ! -f jdk-8u172-linux-x64.rpm ]; then 
  wget -nv --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u172-b11/a58eab1ec242421181065cdc37240b08/jdk-8u172-linux-x64.rpm"
fi
sudo yum -y localinstall jdk-8u172-linux-x64.rpm

if [ ! -f $TOMCAT_ARCHIVE ]; then
  wget -nv $TOMCAT_URL
fi

tar -zxf $TOMCAT_ARCHIVE

#clean up files
rm $TOMCAT_ARCHIVE
rm jdk-8u172-linux-x64.rpm

cp /vagrant/clusterjsp.war $TOMCAT_WEBAPPS
cp /vagrant/tomcat-catalina-jmx-remote.jar $TOMCAT/lib

sed -i -e 's/<Listener className="org.apache.catalina.core.JasperListener"/<Listener \n      className="org.apache.catalina.mbeans.JmxRemoteLifecycleListener"\n      rmiRegistryPortPlatform="8097"\n      rmiServerPortPlatform="8098"\n  \/>\n<Listener className="org.apache.catalina.core.JasperListener"/g' /root/apache-tomcat-7.0.88/conf/server.xml 

$TOMCAT_START



yum install -y http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm 
yum install -y zabbix-agent zabbix-sender zabbix-get jq
sed -i -e 's/Server=127.0.0.1/Server=192.168.56.2/g' /etc/zabbix/zabbix_agentd.conf 
sed -i -e 's/ServerActive=127.0.0.1/ServerActive=192.168.56.2/g' /etc/zabbix/zabbix_agentd.conf 


ERROR='0'
ZABBIX_USER='Admin'
ZABBIX_PASS='zabbix'
ZABBIX_SERVER='192.168.56.2' 
API='http://192.168.56.2/api_jsonrpc.php'
TEMPLATEID=10001 
HOST_NAME=$(hostname)
IP=`hostname -I| cut -d" " -f2`
GROUP_NAME=CloudHosts

authenticate() {
curl -X POST -H 'Content-Type: application/json-rpc' -d "{\"params\": {\"password\": \"$ZABBIX_PASS\", \"user\": \"$ZABBIX_USER\"}, \"jsonrpc\":\"2.0\", \"method\": \"user.login\", \"id\": 1}" $API 
}
AUTH_TOKEN=`echo $(authenticate)|jq -r .result`
echo $AUTH_TOKEN




create_group() {
curl -X POST -H 'Content-Type: application/json-rpc' -d "{ \"jsonrpc\": \"2.0\", \"method\": \"hostgroup.create\", \"params\": { \"name\": \"$GROUP_NAME\"}, \"auth\": \"$AUTH_TOKEN\", \"id\": 1 }" $API
}

if [ ! -f /vagrant/gid ]; then
    HOSTGROUPID=`echo $(create_group)|jq -r .result.groupids`
    echo $HOSTGROUPID >/vagrant/gid
fi


gid=`cat /vagrant/gid |sed 's/[^0-9]*//g'`
echo $gid



create_template() {
curl -X POST -H 'Content-Type: application/json-rpc' -d "{ \"jsonrpc\": \"2.0\", \"method\": \"template.create\", \"params\": { \"host\": \"Custom template\", \"groups\":{ \"groupid\": $gid}}, \"auth\": \"$AUTH_TOKEN\", \"id\": 1 }" $API
}


if [ ! -f /vagrant/tid ]; then
    TEMPLATEID=`echo $(create_template)|jq -r .result.templateids`
    echo $TEMPLATEID >/vagrant/tid
fi
tid=`cat /vagrant/tid |sed 's/[^0-9]*//g'`
echo $tid



create_host() {
curl -X POST -H 'Content-Type: application/json-rpc' -d "{ \"jsonrpc\": \"2.0\", \"method\": \"host.create\", \"params\": { \"host\": \"$HOST_NAME\", \"interfaces\": [ { \"type\": 1, \"main\": 1, \"useip\": 1, \"ip\": \"$IP\", \"dns\": \"\", \"port\": \"10050\" } ], \"groups\": [ { \"groupid\": \"$gid\" } ], \"templates\": [ { \"templateid\": \"$TEMPLATEID\" } ], \"inventory_mode\": 0 } , \"auth\": \"$AUTH_TOKEN\", \"id\": 1 }" $API
   }
output=`echo $(create_host) |jq -r .result.hostids`
echo $output








systemctl start zabbix-agent