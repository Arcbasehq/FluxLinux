set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Install Gnome Extension FluxLinux Location Switcher"
cp ./loc@FluxLinux.xyz /usr/share/gnome-shell/extensions/loc@FluxLinux.com -rf
judge "Install Gnome Extension FluxLinux Location Switcher"