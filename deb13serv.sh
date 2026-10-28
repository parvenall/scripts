#!/bin/bash
echo "enable https apt..."
apt update -y
apt install ca-certificates dirmngr -yq
sed -i 's/http:/https:/g' /etc/apt/sources.list

echo "adding docker and backports repos..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF


. /etc/os-release
echo "deb http://deb.debian.org/debian ${VERSION_CODENAME}-backports main" | \
    sudo tee /etc/apt/sources.list.d/backports.list

apt update -y

echo "installing main packages bunch..."
apt install -y sudo nano gnupg lvm2 net-tools ipset nmap fail2ban ntfs-3g cifs-utils smbclient dconf-cli smartmontools htop iotop tmux unrar dirmngr mc locate curl  wget parted openssl ca-certificates uuid-runtime dnsutils unattended-upgrades apt-listchanges git firewalld -yq
#apt install -y firmware-linux-nonfree

echo "installing docker engine..."
apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

dpkg-reconfigure --priority=low unattended-upgrades

echo "updating db for locate..."
updatedb

git clone -q https://github.com/parvenall/ubuntu-docker-firewall-bootstrap.git  firewalld_cockpit_script
chmod +x ./firewalld_cockpit_script/docker-firewall-cockpit-bootstrap.sh
echo "firewalld & cockpit script now in ./firewalld_cockpit_script. Run: ./firewalld_cockpit_script/docker-firewall-cockpit-bootstrap.sh --allow-ssh-from <YOUR_PUBLIC_IP>/32"

#reboot
