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
apt install -yq sudo nano gnupg lvm2 net-tools ipset nmap fail2ban ntfs-3g cifs-utils smbclient dconf-cli smartmontools htop iotop tmux unrar dirmngr mc locate curl  wget parted openssl ca-certificates uuid-runtime dnsutils unattended-upgrades apt-listchanges git firewalld -yq
#apt install -y firmware-linux-nonfree
echo "installing python..."
apt install -yq python3 python3-pip python3-venv
echo "installing docker engine..."
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

dpkg-reconfigure --priority=low unattended-upgrades

echo "updating db for locate..."
updatedb

echo "setting up for Komodo Periphery..."
curl -sSL --create-dirs -o ~/komodo/setup-periphery.py https://raw.githubusercontent.com/moghtech/komodo/main/scripts/setup-periphery.py
echo "Komodo Periphery script now in ./komodo. Run: python3 ~/komodo/setup-periphery.py --core-address="https://<core-address>" --connect-as="$(hostname)" --onboarding-key="O-...""

echo "setting up user for nginxui..."
useradd -r -s /bin/bash -m -G adm nginxui
mkdir -p /home/nginxui/.ssh
touch /home/nginxui/.ssh/authorized_keys
chown -R nginxui:nginxui /home/nginxui/.ssh
chmod 700 /home/nginxui/.ssh
chmod 600 /home/nginxui/.ssh/authorized_keys
setfacl -R  -m u:nginxui:rwx /etc/nginx
setfacl -dR -m u:nginxui:rwx /etc/nginx

git clone -q https://github.com/parvenall/ubuntu-docker-firewall-bootstrap.git  firewalld_cockpit_script
chmod +x ~/firewalld_cockpit_script/docker-firewall-cockpit-bootstrap.sh
echo "firewalld & cockpit script now in ~/firewalld_cockpit_script. Run: ~/firewalld_cockpit_script/docker-firewall-cockpit-bootstrap.sh --allow-ssh-from <YOUR_PUBLIC_IP>/32"

#reboot
