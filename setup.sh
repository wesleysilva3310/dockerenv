#!/bin/bash

# Updating linux
echo "Updating Linux"
sudo apt update -y && sudo apt upgrade -y
echo "Linux updated!"

# Install sshpass
echo "Installing sshpass"
sudo apt-get install sshpass -y
echo "Installation Complete!"

# Instalar o docker
echo "Installing docker"
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt install docker docker.io -y
sudo usermod -aG docker vagrant
echo "Installation Complete!"

# Installing docker-compose
echo "Installing docker compose"
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo curl \
    -L https://raw.githubusercontent.com/docker/compose/1.29.2/contrib/completion/bash/docker-compose \
    -o /etc/bash_completion.d/docker-compose
echo "Installation Complete!"

# ssh access without need key pairs. initial login: vagrant vagrant
echo "Configuring ssh access"
sudo su -
sleep 5
file=/etc/ssh/sshd_config
cp -p $file $file.old &&
while read key other
do
 case $key in
 PasswordAuthentication) other=yes;;
 PubkeyAuthentication) other=yes;;
 esac
 echo "$key $other"
done < $file.old > $file
systemctl restart sshd
echo "Configuration complete!"


# Configuring dns server
if [ "$HOSTNAME" = dockerenv-dnsserver ];
then
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
sudo unlink /etc/resolv.conf
echo nameserver 8.8.8.8 | sudo tee /etc/resolv.conf
sudo apt install dnsmasq
sudo systemctl restart dnsmasq
sudo cat >>/etc/hosts<<EOF
192.168.1.135         dockerenv-dnsserver
192.168.1.130          dockerenv-gitlab
192.168.1.132         dockerenv-jenkins
192.168.1.136         dockerenv-mongo
EOF
fi

#Adding dns server to resolv.conf
sudo cat >>/etc/resolv.conf<<EOF
nameserver 192.168.1.135
EOF

# Installing ansible on kmaster vm
if
        [ "$HOSTNAME" = dockerenv-ansible ];
then
        echo "Installing ansible on kmaster VM"
        sudo apt install ansible -y
        echo "Installation complete!"
fi

# Installing gitlab on gitlab server
if
        [ "$HOSTNAME" = dockerenv-gitlab ];
then
echo "Installing gitlab on $HOSTNAME"
mkdir /home/vagrant/gitlab
export GITLAB_HOME=/srv/gitlab
export GITLAB_HOME=/home/vagrant/gitlab
cd $GITLAB_HOME

cat > docker-compose.yml << EOF
version: '3.5'
services:
 gitlab:
  image: 'gitlab/gitlab-ee:latest'
  restart: always
  hostname: 'dockerenv-gitlab.wesleylab.com'
  environment:
    GITLAB_OMNIBUS_CONFIG: |
      external_url 'http://dockerenv-gitlab.wesleylab.com'
      # Add any other gitlab.rb configuration here, each on its own line
  ports:
    - '80:80'
    - '443:443'
    - '2224:2224'
  volumes:
    - '$GITLAB_HOME/config:/etc/gitlab'
    - '$GITLAB_HOME/logs:/var/log/gitlab'
    - '$GITLAB_HOME/data:/var/opt/gitlab'
EOF
cd gitlab && docker-compose up -d
# Initial password: docker exec -it gitlab_gitlab_1 cat /etc/gitlab/initial_root_password
echo "Installation complete!"
fi

# Install Jenkins
if
        [ "$HOSTNAME" = dockerenv-jenkins ];
then

mkdir jenkins && cd jenkins
cat > docker-compose.yml << EOF
version: "3.9"
services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins-server
    privileged: true
    hostname: jenkinsserver
    user: root
    labels:
      com.example.description: "Jenkins-Server by DigitalAvenue.dev"
    ports: 
      - "8080:8080"
      - "50000:50000"
    networks:
      jenkins-net:
        aliases: 
          - jenkins-net
    volumes: 
     - jenkins-data:/var/jenkins_home
     - /var/run/docker.sock:/var/run/docker.sock
     
volumes: 
  jenkins-data:
networks:
  jenkins-net:
EOF
fi

#Install mongodb
if
        [ "$HOSTNAME" = dockerenv-mongo ];
then
mkdir /home/vagrant/mongo && cd /home/vagrant/mongo
cat >> docker-compose.yml << EOF
version: '3'

services:
  mongo:
    image: mongo
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: MongoDB2019!
    ports:
      - "27017:27017"
    volumes:
      - /home/MongoDB:/data/db
    networks:
      - mongo-compose-network

networks: 
    mongo-compose-network:
      driver: bridge
EOF
docker-compose up -d
fi