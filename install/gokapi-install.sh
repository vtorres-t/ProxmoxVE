#!/usr/bin/env bash

# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://github.com/vtorres-t/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/Forceu/Gokapi

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Gokapi"
LATEST=$(curl -fsSL https://api.github.com/repos/Forceu/Gokapi/releases/latest | grep '"tag_name":' | cut -d'"' -f4)
mkdir -p /opt/gokapi/{data,config}
curl -fsSL "https://github.com/Forceu/Gokapi/releases/download/$LATEST/gokapi-linux_amd64.zip" -o "gokapi-linux_amd64.zip"
$STD unzip gokapi-linux_amd64.zip -d /opt/gokapi
rm gokapi-linux_amd64.zip
chmod +x /opt/gokapi/gokapi-linux_amd64
msg_ok "Installed Gokapi"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/gokapi.service
[Unit]
Description=gokapi

[Service]
Type=simple
Environment=GOKAPI_DATA_DIR=/opt/gokapi/data
Environment=GOKAPI_CONFIG_DIR=/opt/gokapi/config
ExecStart=/opt/gokapi/gokapi-linux_amd64

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now gokapi
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
