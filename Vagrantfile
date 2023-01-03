ENV['VAGRANT_NO_PARALLEL'] = 'yes'

Vagrant.configure("2") do |config|

  # DNS Server
  config.vm.define "dockerenv-dnsserver" do |dns|
  
    dns.vm.box               = "generic/ubuntu2004"
    dns.vm.box_check_update  = false
    dns.vm.box_version       = "3.3.0"
    dns.vm.hostname          = "dockerenv-dnsserver"

    dns.vm.network "public_network", ip: "192.168.1.135"
    dns.vm.provision "shell", path: "setup.sh"
  end

# Gitlab
config.ssh.insert_key = false

config.vm.define "dockerenv-gitlab" do |gitlab|

  gitlab.vm.box               = "ubuntu/focal64"
  gitlab.vm.hostname          = "dockerenv-gitlab"

  gitlab.vm.network "public_network", ip: "192.168.1.130"
  
  gitlab.vm.provider :virtualbox do |gitlabsetup|
      gitlabsetup.memory = 9000
      gitlabsetup.cpus = 4
      end

  gitlab.vm.network "forwarded_port", guest: 80, host: 80
  gitlab.vm.network "forwarded_port", guest: 443, host: 443
  gitlab.vm.network "forwarded_port", guest: 2224, host: 2224
  gitlab.vm.network "forwarded_port", guest: 5050, host: 5050
  gitlab.vm.provision "shell", path: "setup.sh"
end

# Jenkins Server
config.ssh.insert_key = false

config.vm.define "dockerenv-jenkins" do |jenkins|

  jenkins.vm.box              = "ubuntu/focal64"
  jenkins.vm.hostname         = "dockerenv-jenkins"

  jenkins.vm.network "public_network", ip: "192.168.1.132"

  jenkins.vm.provision "shell", path: "setup.sh"

  jenkins.vm.network "forwarded_port", guest: 8080, host: 8081
  jenkins.vm.network "forwarded_port", guest: 50000, host: 50000
  jenkins.vm.network "forwarded_port", guest: 443, host: 444
end

 # Mongo Server
 config.vm.define "dockerenv-mongo" do |dns|
  
  dns.vm.box               = "generic/ubuntu2004"
  dns.vm.box_check_update  = false
  dns.vm.box_version       = "3.3.0"
  dns.vm.hostname          = "dockerenv-mongo"

  dns.vm.network "public_network", ip: "192.168.1.136"
  dns.vm.provision "shell", path: "setup.sh"
end
# Ansible Server
config.vm.define "dockerenv-ansible" do |dns|
  
  dns.vm.box               = "generic/ubuntu2004"
  dns.vm.box_check_update  = false
  dns.vm.box_version       = "3.3.0"
  dns.vm.hostname          = "dockerenv-ansible"

  dns.vm.network "public_network", ip: "192.168.1.137"
  dns.vm.provision "shell", path: "setup.sh"
end
end