#!/bin/bash
# ZiVPN Auto-Installer - GitHub Version

# 1. Update & Install Dependencies
apt-get update && apt-get install -y python3-pip jq curl wget openssl ufw

# 2. Install Library Telegram
pip3 install pyTelegramBotAPI

# 3. Setup Folder & DB
mkdir -p /etc/zivpn
touch /etc/zivpn/accounts.db
chmod 666 /etc/zivpn/accounts.db

# 4. Download ZiVPN Binary & Default Config dari URL Anda
wget -q https://github.com/fauzanihanipah/ogh-zivpn/raw/main/udp-zivpn-linux-amd64 -O /usr/local/bin/zivpn
chmod +x /usr/local/bin/zivpn

# Mengambil config.json dari URL yang Anda berikan
wget -q https://raw.githubusercontent.com/fauzanihanipah/ziv-udp/main/config.json -O /etc/zivpn/config.json

# 5. Optimasi Kernel
cat <<EOF > /etc/sysctl.d/99-zivpn.conf
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 16384
net.ipv4.udp_rmem_min = 8192
net.ipv4.udp_wmem_min = 8192
EOF
sysctl -p /etc/sysctl.d/99-zivpn.conf

# 6. Buat Service ZiVPN
cat <<EOF > /etc/systemd/system/zivpn.service
[Unit]
Description=ZiVPN UDP Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/etc/zivpn
ExecStart=/usr/local/bin/zivpn server -c /etc/zivpn/config.json
Restart=always
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable zivpn
systemctl start zivpn

echo "Instalasi Selesai! Pastikan edit zivpn_bot.py sebelum dijalankan."
