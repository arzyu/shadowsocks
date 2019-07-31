#! /bin/bash

systemd=/etc/systemd/system
service_name=shadowsocks
service_file="$systemd/$service_name.service"

function set_port() {
	local default_port=8388

	printf "> Set port (default: $default_port): " > /dev/tty
	read port < /dev/tty
	printf "${port:-$default_port}"
}

function set_password() {
	local password=

	while [[ -z $password ]]; do
		printf "> Set password: " > /dev/tty
		read password < /dev/tty
	done

	printf "$password"
}

function add_systemd() {
	local port="$(set_port)"
	local password="$(set_password)"

	if [[ -f $service_file ]]; then
		systemctl stop "$service_name"
		systemctl disable "$service_name" > /dev/null 2>&1
	fi

	cat > "$service_file" <<-EOT
		[Unit]
		Description=shadowsocks
		Requires=docker.service
		After=docker.service

		[Service]
		Restart=Always
		ExecStart=$(which docker) run --rm --name %N -p "$port:8388" -e "PASSWORD=$password" shadowsocks/shadowsocks-libev
		ExecStop=$(which docker) stop %N

		[Install]
		WantedBy=multi-user.target
	EOT

	systemctl daemon-reload
	systemctl enable "$service_name" > /dev/null 2>&1
	systemctl start "$service_name"
}

function remove_systemd() {
	systemctl stop "$service_name"
	systemctl disable "$service_name" > /dev/null 2>&1

	rm "$service_file"

	systemctl daemon-reload

	printf "> Shadowsocks has been removed.\n"
}

function check_service() {
	local max_times=10
	local times=0

	while (( times < max_times )); do
		sleep 1
		if [[ -n $(docker ps --filter "name=$service_name" --format "{{.Names}}") ]]; then
			break
		fi
		(( times++ ))
	done

	if (( times < max_times )); then
		printf "\n> Shadowsocks is running:\n"
		docker ps --filter "name=$service_name" --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}"
		printf "\n"
	else
		printf "\n> Service startup timeout. Run \"docker ps -a\" and have a look.\n"
	fi
}

function main() {
	if [[ $@ == "--remove" ]]; then
		remove_systemd
		exit
	fi

	if [[ ! -x $(command -v docker) ]]; then
		printf "> Install docker:\n"
		curl -fsSL get.docker.com | sh
		printf "\n"
	fi

	add_systemd
	check_service
}

main "$@"
