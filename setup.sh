#! /bin/bash

service_name=shadowsocks

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
	if [[ ! -x $(command -v docker) ]]; then
		printf "> Install docker:\n"
		curl -fsSL get.docker.com | sh
		printf "\n"
	fi

	if [[ -n $(docker ps --all --quiet --filter "name=$service_name") ]]; then
		docker rm "$service_name" --force > /dev/null
	fi

	if [[ $@ == "--remove" ]]; then
		exit
	fi

	local port="$(set_port)"
	local password="$(set_password)"

	docker run --detach --name "$service_name" --restart unless-stopped \
			-p "$port:8388" -e "PASSWORD=$password" shadowsocks/shadowsocks-libev > /dev/null

	check_service
}

main "$@"
