# vim: ft=sh sw=2 ts=2 sts=2

# simplified systemd command, for instance
# "sudo systemctl stop xxx" - > "0.stop xxx"
0.reboot() {
    systemctl reboot "$@"
}

0.off() {
    systemctl poweroff "$@"
}

# start systemd service
0.start() {
    sudo systemctl start "$@"
}
# restart systemd service
0.restart() {
    sudo systemctl restart "$@"
}
# stop systemd service
0.stop() {
    sudo systemctl stop "$@"
}
# enable systemd service
0.enable() {
    sudo systemctl enable "$@"
}
# disable a systemd service
0.disable() {
    sudo systemctl disable "$@"
}
# show the status of a service
0.status() {
    systemctl status "$@"
}
# reload a service configuration
0.reload() {
    sudo systemctl --system daemon-reload
}
# list all running service
0.list() {
    systemctl
}
# list all failed service
0.failed () {
    systemctl --failed
}
# list all systemd available unit files
0.list-files() {
    systemctl list-unit-files
}
# check the log
0.log() {
    sudo journalctl --follow --this-boot "$@"
}
# show wants
0.wants() {
    systemctl show -p "Wants" $1.target
}
# analyze the system
0.analyze() {
    systemd-analyze "$@"
}

# Same as above, but for user services.

# start systemd service
1.start() {
    systemctl --user start "$@"
}
# restart systemd service
1.restart() {
    systemctl --user restart "$@"
}
# stop systemd service
1.stop() {
    systemctl --user stop "$@"
}
# enable systemd service
1.enable() {
    systemctl --user enable "$@"
}
# disable a systemd service
1.disable() {
    systemctl --user disable "$@"
}
# show the status of a service
1.status() {
    systemctl --user status "$@"
}
# reload a service configuration
1.reload() {
    systemctl --user daemon-reload
}
# list all running service
1.list() {
    systemctl --user
}
# list all failed service
1.failed () {
    systemctl --user --failed
}
# list all systemd available unit files
1.list-files() {
    systemctl --user list-unit-files
}
# check the log
1.log() {
    journalctl --user --follow --this-boot "$@"
}
# show wants
1.wants() {
    systemctl show -p "Wants" $1.target
}
