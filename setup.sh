#! /bin/bash

set -e

cd "$(dirname "$0")"

base_dir="$PWD"

systemd=/etc/systemd/system

cat > "$systemd/shadowsocks.service" << EOT
[Unit]
Description=shadowsocks
Requires=docker.service
After=docker.service

[Service]
Restart=Always
ExecStart=$(which docker-compose) --file "$base_dir/docker-compose.yml" up --force-recreate
ExecStop=$(which docker-compose) --file "$base_dir/docker-compose.yml" down

[Install]
WantedBy=multi-user.target

EOT

systemctl daemon-reload
systemctl enable shadowsocks.service
systemctl start shadowsocks.service
