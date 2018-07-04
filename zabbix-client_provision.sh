yum install -y http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm 
yum install -y zabbix-agent
sed -i -e 's/Server=127.0.0.1/Server=192.168.56.2/g' /etc/zabbix/zabbix_agentd.conf 
sed -i '/ServerActive=/s/^/#/g' /etc/zabbix/zabbix_agentd.conf
systemctl start zabbix-agent