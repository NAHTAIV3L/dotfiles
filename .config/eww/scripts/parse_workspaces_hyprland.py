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
            workspaces_str = subprocess.run(["hyprctl", "workspaces", "-j"], capture_output=True)
            workspaces_json = json.loads(workspaces_str.stdout)

            active_str = subprocess.run(["hyprctl", "activeworkspace", "-j"], capture_output=True)
            active_json = json.loads(active_str.stdout)
            active_monitor = active_json["monitorID"]
            active_id = active_json["id"] - 9 * active_monitor

            payload = {"monitors": []}
            for workspace in workspaces_json:
                monitor = int(workspace["monitorID"])
                if len(payload["monitors"]) < monitor + 1:
                    payload["monitors"].append({"workspaces": []})

            for workspace in workspaces_json:
                monitor = int(workspace["monitorID"])
                id = 0
                if str(workspace["id"]) != workspace["name"]:
                    id = workspace["name"]
                else:
                    id = workspace["id"] - 9 * monitor
                if "special" in str(id):
                    continue
                windows = workspace["windows"]
                clas = "workspace_active"
                string = "○"
                if (id == active_id and monitor == active_monitor):
                    clas = "workspace_focused"
                    string = "●"
                elif (windows == 0):
                    clas = "workspace_empty"
                payload["monitors"][monitor]["workspaces"].append({
                    "id": id,
                    "str": string,
                    "class": clas
                })

            for monitor in payload["monitors"]:
                monitor["workspaces"].sort(key=lambda x: (x["id"]))

            print(json.dumps(payload), flush=True)

            try:
                _ = socket_client.recv(1024).decode()
            except:
                break

if __name__ == "__main__":
    main()
