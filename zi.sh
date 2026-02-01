#!/bin/bash
# Zivpn UDP Installer & Manager - PRO SELLER EDITION
# Optimized & Fixed by Gemini

# --- Configuration & Path ---
CONFIG_FILE="/etc/zivpn/config.json"
BIN_FILE="/usr/local/bin/zivpn"
DB_FILE="/etc/zivpn/accounts.db"
DOMAIN_FILE="/etc/zivpn/domain"

# --- Color Definitions ---
PURPLE_RED='\e[1;35m'
RED='\e[1;31m'
DEEP_BLUE='\e[0;34m'
WHITE='\e[1;37m'
CYAN='\e[1;36m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
NC='\e[0m'

# --- Initialization ---
mkdir -p /etc/zivpn
touch $DB_FILE

# --- Helper: Get Public IP ---
get_ip() {
    local ip=$(curl -sS4 ifconfig.me || curl -sS4 ip.sb || echo "Unknown")
    echo "$ip"
}

# --- Function: Logo & System Info ---
show_logo() {
    clear
    echo -e "${PURPLE_RED}  ________  ___  ___      ___ ________  ________      "
    echo -e " |\_____  \|\  \|\  \    /  /|\   __  \|\   ___  \    "
    echo -e "  \|___/  /\ \  \ \  \  /  / | \  \|\  \ \  \\ \  \   "
    echo -e "      /  / /\ \  \ \  \/  / / \ \   ____\ \  \\ \  \  "
    echo -e "     /  /_/__\ \  \ \    / /   \ \  \___|\ \  \\ \  \ "
    echo -e "    |\________\ \__\ \__/ /     \ \__\    \ \__\\ \__\\"
    echo -e "     \|_______|\|__|\|__|/       \|__|     \|__| \|__|${NC}"
    echo -e "${RED}                UDP CUSTOM - POTATO EDITION ${NC}"
    echo -e "${PURPLE_RED}══════════════════════════════════════════════════════${NC}"
    
    local ip_addr=$(get_ip)
    local os_name=$(grep -P '^PRETTY_NAME' /etc/os-release | cut -d '"' -f 2)
    local domain=$(cat $DOMAIN_FILE 2>/dev/null || echo "Belum Diatur")
    
    echo -e "${WHITE} OS         : $os_name"
    echo -e " Public IP  : $ip_addr"
    echo -e " Domain     : $domain${NC}"
    echo -e "${PURPLE_RED}══════════════════════════════════════════════════════${NC}"
}

# --- Function: Optimasi Potato (Speed Up) ---
optimasi_potato() {
    show_logo
    echo -e "${YELLOW}[!] Menerapkan Optimasi Potato...${NC}"
    
    # Kernel Tweak untuk UDP
    cat <<EOF > /etc/sysctl.d/99-zivpn-pro.conf
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.rmem_default = 16777216
net.core.wmem_default = 16777216
net.core.netdev_max_backlog = 16384
net.core.somaxconn = 4096
net.ipv4.udp_rmem_min = 8192
net.ipv4.udp_wmem_min = 8192
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
EOF
    sysctl -p /etc/sysctl.d/99-zivpn-pro.conf > /dev/null 2>&1
    echo -e "${GREEN}[✔] Optimasi Berhasil Diterapkan!${NC}"
}

# --- Function: Install/Update ZiVPN ---
install_zivpn() {
    show_logo
    echo -e "${YELLOW}[!] Memulai Instalasi/Update ZiVPN...${NC}"
    apt-get update && apt-get install -y jq curl openssl ufw bc
    
    wget -q https://github.com/fauzanihanipah/ogh-zivpn/raw/main/udp-zivpn-linux-amd64 -O $BIN_FILE
    chmod +x $BIN_FILE
    
    if [ ! -f "$CONFIG_FILE" ]; then
        wget -q https://raw.githubusercontent.com/zahidbd2/udp-zivpn/main/config.json -O $CONFIG_FILE
    fi

    # Generate Certs
    openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=ID/ST=ZIVPN/L=ZIVPN/O=ZIVPN/OU=IT/CN=zivpn" -keyout "/etc/zivpn/zivpn.key" -out "/etc/zivpn/zivpn.crt"
    
    # Create Systemd Service
    cat <<EOF > /etc/systemd/system/zivpn.service
[Unit]
Description=ZiVPN UDP Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/etc/zivpn
ExecStart=$BIN_FILE server -c $CONFIG_FILE
Restart=always
RestartSec=3
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable zivpn
    systemctl restart zivpn
    
    # Firewall & Iptables
    ETH=$(ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1)
    iptables -t nat -D PREROUTING -i $ETH -p udp --dport 6000:19999 -j DNAT --to-destination :5667 2>/dev/null
    iptables -t nat -A PREROUTING -i $ETH -p udp --dport 6000:19999 -j DNAT --to-destination :5667
    ufw allow 6000:19999/udp >/dev/null 2>&1
    ufw allow 5667/udp >/dev/null 2>&1
    
    optimasi_potato
    echo -e "${GREEN}[✔] ZiVPN UDP Berhasil Terpasang!${NC}"
}

# --- Function: Manage Accounts ---
create_account() {
    show_logo
    echo -e "${CYAN}[ TAMBAH AKUN BARU ]${NC}"
    read -p " Masukkan Password : " user_pass
    [[ -z "$user_pass" ]] && { echo -e "${RED}Error: Password kosong!${NC}"; return; }
    
    if jq -e ".config | contains([\"$user_pass\"])" $CONFIG_FILE >/dev/null 2>&1; then
        echo -e "${RED}Error: Password sudah digunakan!${NC}"; return;
    fi

    read -p " Masa Aktif (Hari) : " exp_days
    exp_date=$(date -d "+$exp_days days" +"%Y-%m-%d")
    
    jq ".config += [\"$user_pass\"]" $CONFIG_FILE > tmp.json && mv tmp.json $CONFIG_FILE
    echo "$user_pass|$exp_date" >> $DB_FILE
    systemctl restart zivpn
    
    local host=$(cat $DOMAIN_FILE 2>/dev/null || get_ip)
    echo -e "\n${GREEN}======= DETAIL AKUN PEMBELI =======${NC}"
    echo -e " Host/IP  : $host"
    echo -e " Password : $user_pass"
    echo -e " Port UDP : 6000-19999"
    echo -e " Expired  : $exp_date ($exp_days Hari)"
    echo -e "${GREEN}===================================${NC}"
    echo -e " Format: ${WHITE}$host|$user_pass|$exp_date${NC}"
}

list_accounts() {
    echo -e "${CYAN} ID |   PASSWORD   |   EXPIRED    |   STATUS   ${NC}"
    echo -e "------------------------------------------------------"
    local i=1
    local today=$(date +"%Y-%m-%d")
    while IFS='|' read -r pass exp; do
        [[ -z "$pass" ]] && continue
        if [[ "$today" > "$exp" ]]; then
            status="${RED}EXPIRED${NC}"
        else
            status="${GREEN}ACTIVE${NC}"
        fi
        printf " %-2s | %-12s | %-12s | %b\n" "$i" "$pass" "$exp" "$status"
        ((i++))
    done < $DB_FILE
    echo -e "------------------------------------------------------"
}

delete_account() {
    show_logo
    list_accounts
    read -p " Masukkan Password yang akan dihapus: " del_pass
    if jq -e ".config | contains([\"$del_pass\"])" $CONFIG_FILE >/dev/null 2>&1; then
        jq ".config -= [\"$del_pass\"]" $CONFIG_FILE > tmp.json && mv tmp.json $CONFIG_FILE
        sed -i "/^$del_pass|/d" $DB_FILE
        systemctl restart zivpn
        echo -e "${GREEN}Sukses: Akun '$del_pass' dihapus.${NC}"
    else
        echo -e "${RED}Error: Password tidak ditemukan!${NC}"
    fi
}

# --- Main Menu Loop ---
while true; do
    show_logo
    echo -e "${DEEP_BLUE} [1] Buat Akun Baru (Jualan)"
    echo -e " [2] Hapus Akun"
    echo -e " [3] Daftar Akun & Cek Expired"
    echo -e " [4] Atur Domain Server"
    echo -e " [5] Install / Update Service"
    echo -e " [6] Jalankan Optimasi Potato"
    echo -e " [7] Keluar${NC}"
    echo -e "${PURPLE_RED}══════════════════════════════════════════════════════${NC}"
    read -p " Pilih Menu [1-7]: " opt

    case $opt in
        1) create_account; read -p " Press Enter..." ;;
        2) delete_account; read -p " Press Enter..." ;;
        3) show_logo; list_accounts; read -p " Press Enter..." ;;
        4) read -p " Masukkan Domain: " dom; [[ -n "$dom" ]] && echo "$dom" > $DOMAIN_FILE; read -p " Done! Press Enter..." ;;
        5) install_zivpn; read -p " Press Enter..." ;;
        6) optimasi_potato; read -p " Press Enter..." ;;
        7) clear; exit 0 ;;
        *) echo -e "${RED}Pilihan salah!${NC}"; sleep 1 ;;
    esac
done
