set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Install Gnome Extension FluxLinux Switcher"
cp ./switcher@fluxlinux /usr/share/gnome-shell/extensions/switcher@fluxlinux -rf
judge "Install Gnome Extension FluxLinux Switcher"