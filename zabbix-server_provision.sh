#!/bin/bash
#installing database
yum install -y vim net-tools mariadb mariadb-server
/usr/bin/mysql_install_db --user=mysql
systemctl start mariadb
mysql -uroot -Bse "create database zabbix character set utf8 collate utf8_bin; grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';"

#installing zabbix
yum install -y http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm
yum install -y zabbix-server-mysql zabbix-web-mysql zabbix-agent zabbix-sender zabbix-get zabbix-java-gateway
zcat /usr/share/doc/zabbix-server-mysql-3.4.11/create.sql.gz |mysql -uzabbix -pzabbix zabbix
sed -i '/DBPassword=/s/^#*//g' /etc/zabbix/zabbix_server.conf
sed -i '/DBHost=/s/^#*//g' /etc/zabbix/zabbix_server.conf
sed -i -e 's/DBPassword=/DBPassword=zabbix/g' /etc/zabbix/zabbix_server.conf
systemctl start zabbix-server
cp /vagrant/zabbix.conf.php /etc/zabbix/web/
sed -i -e 's/# php_value date\.timezone Europe\/Riga/php_value date\.timezone Europe\/Minsk/g' /etc/httpd/conf.d/zabbix.conf
systemctl start httpd
sed -i -e 's/#DocumentRoot "\/var\/www\/html"/DocumentRoot "\/usr\/share\/zabbix"/g' /etc/httpd/conf/httpd.conf
systemctl start zabbix-agent

