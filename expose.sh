#!/bin/bash

# script by github.com/htr-tech

line="~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
port="3000"
ip="127.0.0.1"

echo $line

### install package

install_package() {
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

download_binaries() {
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

download_expose() {
architecture=`uname -m`

        if [[ -e "./expose" ]]; then
                echo "Cloudflared already installed."
        else
                echo "Installing Cloudflared..."
                if [[ ("$architecture" == *'arm'*) || ("$architecture" == *'Android'*) ]]; then
                        download_binaries 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm' 'expose'
                elif [[ "$architecture" == *'aarch64'* ]]; then
                        download_binaries 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64' 'expose'
                elif [[ "$architecture" == *'x86_64'* ]]; then
                        download_binaries 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64' 'expose'
                else
                        download_binaries 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386' 'expose'
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
        check_PID="expose"
        for process in ${check_PID}; do
                if [[ $(pidof ${process}) ]]; then
                        killall ${process} > /dev/null 2>&1
                fi
        done
}

start_expose() {

echo -e -n "Please enter your ip (default is 127.0.0.1): "
read custom_ip

if [[ $custom_ip != "" ]]; then
        ip=$custom_ip
fi

echo -e -n "Please enter your port (default is 3000): "
read custom_port

if [[ $custom_port != "" ]]; then
        port=$custom_port
fi

localhost="$ip:$port"

echo $line
echo "Your local host is: http://$localhost"
echo "Starting expose your localhost"

./expose tunnel -url http://$localhost

}

install_package
download_expose
start_expose
