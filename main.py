import platform
import urllib.request
import os
import psutil

def kill_process_by_name(process_name):
    for proc in psutil.process_iter(['pid', 'name']):
        if proc.info['name'] == process_name:
            pid = proc.info['pid']
            process = psutil.Process(pid)
            process.terminate()
            return True
    return False

# Example usage
process_name = "php"
success = kill_process_by_name(process_name)
if success:
    print(f"Successfully killed process with name '{process_name}'.")
else:
    print(f"No process found with name '{process_name}'.")


kill_process_by_name("cloudflared")
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
    input_localhost()

if os.path.exists("cloudflared"):
    print("File cloudflared exists.")
    input_localhost()
else:
    download_cloudflared()
