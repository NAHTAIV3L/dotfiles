#!/usr/bin/env python3

import json
import subprocess

import socket
import os, os.path
import sys

HYPRLAND_INSTANCE_SIGNATURE = os.getenv('HYPRLAND_INSTANCE_SIGNATURE')
SOCKET_PATH = f"/tmp/nahtaiv3l/hypr/{HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"

def main():
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as socket_client:
        socket_client.connect(SOCKET_PATH)
        while True:
            info=""
            try:
                info = socket_client.recv(1024).decode()
            except:
                break
            lines = info.split("\n")
            for line in lines:
                parts = line.split(">>")
                if parts[0] == "monitoraddedv2":
                    print(parts)
                    monitor_number = parts[1].split(',')[0]
                    subprocess.run(["eww", "open-many", f"bar:{monitor_number}", "--arg", f"{monitor_number}:monitor={monitor_number}"])
                elif parts[0] == "openlayer" and parts[1] == "hyprpaper":
                    subprocess.run(["eww", "reload"])


if __name__ == "__main__":
    main()
