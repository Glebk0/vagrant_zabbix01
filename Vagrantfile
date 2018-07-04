Vagrant.configure("2") do |config|
	config.vm.define "zabbix-server" do |zabbixserver|
		zabbixserver.vm.box = "sbeliakou/centos-7.4-x86_64-minimal"
		zabbixserver.vm.hostname = 'zabbix-server'
		zabbixserver.vm.box_url = "sbeliakou/centos-7.4-x86_64-minimal"
		zabbixserver.vm.network :private_network, ip: "192.168.56.2"
		zabbixserver.vm.provision "shell", path: "content/zabbix-server_provision.sh"		
		zabbixserver.vm.provider :virtualbox do |v|
			v.customize ["modifyvm", :id, "--memory", 2048]
			v.customize ["modifyvm", :id, "--name","zabbix-server"]
  		end
end
	config.vm.define "zabbix-client" do |zabbixclient|
		zabbixclient.vm.box = "sbeliakou/centos-7.4-x86_64-minimal"
		zabbixclient.vm.hostname = 'zabbix-client'
		zabbixclient.vm.box_url = "sbeliakou/centos-7.4-x86_64-minimal"
		zabbixclient.vm.network :private_network, ip: "192.168.56.3"
		#zabbixclient.vm.provision "shell", path: "content/zabbix-server_provision2.sh"		
		zabbixclient.vm.provider :virtualbox do |v|
			v.customize ["modifyvm", :id, "--memory", 2048]
			v.customize ["modifyvm", :id, "--name","zabbix-client"]
  		end
end

end
