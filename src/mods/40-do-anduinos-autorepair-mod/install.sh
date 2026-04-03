set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Adding new command to this OS: do-FluxLinux-autorepair..."
cp ./do-FluxLinux-autorepair.sh /usr/local/bin/do-FluxLinux-autorepair
chmod +x /usr/local/bin/do-FluxLinux-autorepair
judge "Add new command do-FluxLinux-autorepair"
