#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/vtorres-t/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: vhsdream
# License: MIT | https://github.com/vtorres-t/ProxmoxVE/raw/main/LICENSE
# Source: https://rxresu.me

APP="Reactive-Resume"
var_tags="${var_tags:-documents}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-3072}"
var_disk="${var_disk:-8}"
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

    if [[ ! -f /etc/systemd/system/Reactive-Resume.service ]]; then
        msg_error "No ${APP} Installation Found!"
        exit
    fi
    RELEASE=$(curl -fsSL https://api.github.com/repos/AmruthPillai/Reactive-Resume/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
    if [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]] || [[ ! -f /opt/${APP}_version.txt ]]; then
        msg_info "Stopping services"
        systemctl stop Reactive-Resume
        msg_ok "Stopped services"

        msg_info "Updating $APP to v${RELEASE}"
        cp /opt/${APP}/.env /opt/rxresume.env
        res_tmp=$(mktemp)
        rm -rf /opt/${APP}
        curl -fsSL "https://github.com/AmruthPillai/Reactive-Resume/archive/refs/tags/v${RELEASE}.zip" -O $res_tmp
        $STD unzip $res_tmp
        mv ${APP}-${RELEASE}/ /opt/${APP}
        cd /opt/${APP}
        export PUPPETEER_SKIP_DOWNLOAD="true"
        export NEXT_TELEMETRY_DISABLED=1
        export CI="true"
        export NODE_ENV="production"
        $STD pnpm install --frozen-lockfile
        $STD pnpm run build
        $STD pnpm run prisma:generate
        mv /opt/rxresume.env /opt/${APP}/.env
        msg_ok "Updated $APP to v${RELEASE}"

        msg_info "Updating Minio"
        systemctl stop minio
        cd /tmp
        curl -fsSL https://dl.min.io/server/minio/release/linux-amd64/minio.deb -o minio.deb
        $STD dpkg -i minio.deb
        msg_ok "Updated Minio"

        msg_info "Updating Browserless (Patience)"
        systemctl stop browserless
        cp /opt/browserless/.env /opt/browserless.env
        rm -rf browserless
        brwsr_tmp=$(mktemp)
        TAG=$(curl -fsSL https://api.github.com/repos/browserless/browserless/tags?per_page=1 | grep "name" | awk '{print substr($2, 3, length($2)-4) }')
        curl -fsSL https://github.com/browserless/browserless/archive/refs/tags/v${TAG}.zip -O $brwsr_tmp
        $STD unzip $brwsr_tmp
        mv browserless-${TAG}/ /opt/browserless
        cd /opt/browserless
        $STD npm install
        rm -rf src/routes/{chrome,edge,firefox,webkit}
        $STD node_modules/playwright-core/cli.js install --with-deps chromium
        $STD npm run build
        $STD npm run build:function
        $STD npm prune production
        mv /opt/browserless.env /opt/browserless/.env
        msg_ok "Updated Browserless"

        msg_info "Restarting services"
        systemctl start minio Reactive-Resume browserless
        msg_ok "Restarted services"

        msg_info "Cleaning Up"
        rm -f /tmp/minio.deb
        rm -f $brwsr_tmp
        rm -f $res_tmp
        msg_ok "Cleanup Completed"

        echo "${RELEASE}" >/opt/${APP}_version.txt
        msg_ok "Update Successful"
    else
        msg_ok "No update required. ${APP} is already at v${RELEASE}"
    fi
    exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:3000${CL}"
