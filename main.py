import platform
import urllib.request
import os

architecture = platform.machine()

def tunnel(ip, port):
    print("Starting server cloudflared...")
    os.system("./cloudflared tunnel -url " + ip+":"+port)

def input_localhost():
    ip="127.0.0.1"
    port="3000"

    input_ip = input("Enter your network ip (default is 127.0.0.1): ")
    input_port = input("Enter your port (default is 3000): ")

    if input_port != "":
        port=input_port

    if input_ip != "":
        ip=input_ip

    tunnel(ip, port)


def download_cloudflared():
    print("Downloading cloudflared...")
    url = ""
    filename = "cloudflared"

    if architecture == 'arm' or architecture == 'Android':
        url = "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm"
    elif architecture == 'aarch64':
        url = "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64"
    elif architecture == 'x86_64':
        url = "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64"
    else:
        url = "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386"

    # Download the file
    urllib.request.urlretrieve(url, filename)
    print("Download completed!")


if os.path.exists("cloudflared"):
    print("File cloudflared exists.")
    input_localhost()
else:
    download_cloudflared()
