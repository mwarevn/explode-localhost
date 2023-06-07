#!/bin/bash

# Deafult Port
port='3000'

architecture=`uname -m`

install_require_package(){
	if [[ $(command -v curl) && $(command -v unzip) ]]; then
		echo "Environment Setup Completed !"
	else
		repr=(curl unzip)
		for i in "${repr[@]}"; do
			type -p "$i" &>/dev/null || 
				{ 
					echo "Installing ${i}"
		
					if [[ $(command -v apt) ]]; then
						sudo apt install "$i" -y
					elif [[ $(command -v apt-get) ]]; then
						sudo apt-get install "$i" -y
					elif [[ $(command -v dnf) ]]; then
						sudo dnf -y install "$i"
					else
						echo "Unfamiliar Distro !"
						exit 1
					fi
				}
		done
	fi
}

## Download Binaries
download() {
	url="$1"
	output="$2"
	file=`basename $url`
	if [[ -e "$file" || -e "$output" ]]; then
		rm -rf "$file" "$output"
	fi
	curl --silent --insecure --fail --retry-connrefused \
		--retry 3 --retry-delay 2 --location --output "${file}" "${url}"

	if [[ -e "$file" ]]; then
		if [[ ${file#*.} == "zip" ]]; then
			unzip -qq $file > /dev/null 2>&1
		elif [[ ${file#*.} == "tgz" ]]; then
			tar -zxf $file > /dev/null 2>&1
		else
			mv -f $file $output > /dev/null 2>&1
		fi
		chmod +x $output > /dev/null 2>&1
		rm -rf "$file"
	else
		echo -e "Error occured while downloading ${output}."
		exit 1
	fi
}

## Install Cloudflared
install_cloudflared_library() {
	if [[ -e "./cloudflared" ]]; then
		echo "Cloudflared already installed."
	else
		echo "Installing Cloudflared..."
		if [[ ("$architecture" == *'arm'*) || ("$architecture" == *'Android'*) ]]; then
			download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm' 'cloudflared'	
		elif [[ "$architecture" == *'aarch64'* ]]; then
			download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64' 'cloudflared'
		elif [[ "$architecture" == *'x86_64'* ]]; then
			download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64' 'cloudflared'
		else
			download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386' 'cloudflared'
		fi
	fi
}


# Terminate Program
terminated() {
	kill_pid
	exit 1
}

trap terminated SIGTERM
trap terminated SIGINT

kill_pid() {
	check_PID="cloudflared"
	for process in ${check_PID}; do
		if [[ $(pidof ${process}) ]]; then
			killall ${process} > /dev/null 2>&1
		fi
	done
}

start(){

	install_require_package
	install_cloudflared_library

	echo -e -n "Enter port (default is 3000): "
	read customPort

	if [[ "$customPort" != "" ]]; then
		port=$customPort
	fi

	./cloudflared tunnel -url 127.0.0.1:"$port"
}

start
