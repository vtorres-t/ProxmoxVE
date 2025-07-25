#!/usr/bin/env bash

# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://github.com/vtorres-t/ProxmoxVE/raw/main/LICENSE
# Source: https://homebridge.io/

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y avahi-daemon
msg_ok "Installed Dependencies"

msg_info "Setting up Homebridge Repository"
curl -fsSL https://repo.homebridge.io/KEY.gpg | gpg --dearmor >/etc/apt/trusted.gpg.d/homebridge.gpg
echo 'deb [signed-by=/etc/apt/trusted.gpg.d/homebridge.gpg] https://repo.homebridge.io stable main' >/etc/apt/sources.list.d/homebridge.list
msg_ok "Set up Homebridge Repository"

msg_info "Installing Homebridge"
$STD apt update
$STD apt-get install -y homebridge
msg_ok "Installed Homebridge"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
