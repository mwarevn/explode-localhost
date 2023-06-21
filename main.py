import platform
import urllib.request
import os
import psutil
import time
import json
import signal
import sys

def kill_process_by_name(process_name):
    if os.path.exists('cloudflared.json'):
        os.remove('cloudflared.json')
    for proc in psutil.process_iter(['pid', 'name']):
        if proc.info['name'] == process_name:
            proc.terminate()
            return True
    return False

kill_process_by_name("cloudflared")

def exit_handler(signal, frame):
    kill_process_by_name('cloudflared')
    sys.exit(0)

signal.signal(signal.SIGINT, exit_handler)

architecture = platform.machine()

def tunnel(ip, port):
    print("Starting server cloudflared...")
    os.system(f"./cloudflared tunnel -url {ip}:{port} --logfile cloudflared.json > /dev/null 2>&1 &")
    time.sleep(8)

    filename = "cloudflared.json"

    with open(filename, "r") as file:
        data = file.readlines()

    url = next((json.loads(line)["message"].strip().split()[1] for line in data if "message" in json.loads(line) and ".trycloudflare.com" in json.loads(line)["message"]), None)

    if url:
        print("Your URL is: " + url)
        while os.path.exists('cloudflared.json'):
            time.sleep(2)
    else:
        print("URL not found in the file.")

def input_localhost():
    ip = input("Enter your network IP (default is 127.0.0.1): ") or "127.0.0.1"
    port = input("Enter your port (default is 3000): ") or "3000"
    tunnel(ip, port)

def download_cloudflared():
    print("Downloading cloudflared...")
    architecture_map = {
        'arm': 'cloudflared-linux-arm',
        'aarch64': 'cloudflared-linux-arm64',
        'x86_64': 'cloudflared-linux-amd64',
        'Android': 'cloudflared-linux-arm'  # Assuming Android uses ARM architecture
    }
    filename = architecture_map.get(platform.machine(), 'cloudflared-linux-386')
    url = f"https://github.com/cloudflare/cloudflared/releases/latest/download/{filename}"
    urllib.request.urlretrieve(url, filename)
    os.rename(filename, 'cloudflared')  # Rename the file
    print("Download completed!")
    input_localhost()

if os.path.exists("cloudflared"):
    print("File cloudflared installed!")
    input_localhost()
else:
    download_cloudflared()
