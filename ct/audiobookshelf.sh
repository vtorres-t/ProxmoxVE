#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/vtorres-t/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://github.com/vtorres-t/ProxmoxVE/raw/main/LICENSE
# Source: https://www.audiobookshelf.org/

APP="audiobookshelf"
var_tags="${var_tags:-podcast;audiobook}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-12}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
    header_info
    check_container_storage
    check_container_resources
    if [[ ! -f /etc/apt/trusted.gpg.d/audiobookshelf-ppa.asc ]]; then
        msg_error "No ${APP} Installation Found!"
        exit
    fi
    echo "This application receives updates through the APT package manager."
    exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:13378${CL}"
