#! /bin/bash

service_name=shadowsocks

function set_port() {
	local default_port=8388

	printf "> Set port (default: $default_port): " > /dev/tty
	read port < /dev/tty
	printf "${port:-$default_port}"
}

function get_port() {
	local container_id=$1
	local port=$(docker inspect $container_id \
			--format '{{(index (index .HostConfig.PortBindings "8388/tcp") 0).HostPort}}')

	printf "$port"
}

function set_password() {
	local password=

	while [[ -z $password ]]; do
		printf "> Set password: " > /dev/tty
		read password < /dev/tty
	done

	printf "$password"
}

function get_password() {
	local container_id=$1
	local password=$(docker inspect $container_id \
			--format='{{range .Config.Env}}{{println .}}{{end}}' \
			| grep -E "^PASSWORD=" | sed 's/[^=]*=//')

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

function docker_run() {
	docker run --detach --name "$1" --restart unless-stopped \
			-p "$2:8388" -e "PASSWORD=$3" shadowsocks/shadowsocks-libev > /dev/null
}

function main() {
	if [[ ! -x $(command -v docker) ]]; then
		printf "> Install docker:\n"
		curl -fsSL get.docker.com | sh
		printf "\n"
	fi

	local port=
	local password=
	local container_id=$(docker ps --all --quiet --filter "name=$service_name")

	if [[ $@ == "update" ]]; then
		if [[ -n $container_id ]]; then
			port=$(get_port "$container_id")
			password=$(get_password "$container_id")
			docker rm "$container_id" --force > /dev/null
		fi
		docker image rm shadowsocks/shadowsocks-libev --force > /dev/null 2>&1
		docker pull shadowsocks/shadowsocks-libev
		docker_run "$service_name" "${port:-$(set_port)}" "${password:-$(set_password)}"
		check_service

	elif [[ $@ == "remove" ]]; then
		if [[ -n $container_id ]]; then
			docker rm "$container_id" --force > /dev/null
		fi
		docker image rm shadowsocks/shadowsocks-libev --force > /dev/null 2>&1

	else
		if [[ -n $container_id ]]; then
			docker rm "$container_id" --force > /dev/null
		fi
		docker_run "$service_name" "${port:-$(set_port)}" "${password:-$(set_password)}"
		check_service
	fi
}

main "$@"
