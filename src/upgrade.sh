#!/bin/bash
#==========================
# Set up the environment
#==========================
set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error
export DEBIAN_FRONTEND=noninteractive
export LATEST_VERSION="1.5.0"
export CODE_NAME="resolute"
export OS_ID="FluxLinux"
export CURRENT_VERSION=$(cat /etc/lsb-release | grep DISTRIB_RELEASE | cut -d "=" -f 2)

#==========================
# Color
#==========================
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
Blue="\033[36m"
Font="\033[0m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
OK="${Green}[  OK  ]${Font}"
ERROR="${Red}[FAILED]${Font}"
WARNING="${Yellow}[ WARN ]${Font}"

#==========================
# Print Colorful Text
#==========================
function print_ok() {
  echo -e "${OK} ${Blue} $1 ${Font}"
}

function print_error() {
  echo -e "${ERROR} ${Red} $1 ${Font}"
}

function print_warn() {
  echo -e "${WARNING} ${Yellow} $1 ${Font}"
}

#==========================
# Judge function
#==========================
function judge() {
  if [[ 0 -eq $? ]]; then
    print_ok "$1 succeeded"
    sleep 0.2
  else
    print_error "$1 failed"
    exit 1
  fi
}

function ensureCurrentOsFluxLinux() {
    # Ensure the current OS is FluxLinux
    if ! grep -q "DISTRIB_ID=FluxLinux" /etc/lsb-release; then
        print_error "This script can only be run on FluxLinux."
        exit 1
    fi
}

function applyLsbRelease() {

    # Update /etc/os-release
    sudo bash -c "cat > /etc/os-release <<EOF
PRETTY_NAME=\"FluxLinux $LATEST_VERSION\"
NAME=\"FluxLinux\"
VERSION_ID=\"$LATEST_VERSION\"
VERSION=\"$LATEST_VERSION ($CODE_NAME)\"
VERSION_CODENAME=$CODE_NAME
ID=ubuntu
ID_LIKE=debian
HOME_URL=\"https://www.FluxLinux.com/\"
SUPPORT_URL=\"https://github.com/FluxLinux2017/FluxLinux/discussions\"
BUG_REPORT_URL=\"https://github.com/FluxLinux2017/FluxLinux/issues\"
PRIVACY_POLICY_URL=\"https://www.ubuntu.com/legal/terms-and-policies/privacy-policy\"
UBUNTU_CODENAME=$CODE_NAME
EOF"

    # Update /etc/lsb-release
    sudo bash -c "cat > /etc/lsb-release <<EOF
DISTRIB_ID=FluxLinux
DISTRIB_RELEASE=$LATEST_VERSION
DISTRIB_CODENAME=$CODE_NAME
DISTRIB_DESCRIPTION=\"FluxLinux $LATEST_VERSION\"
EOF"

    # Update /etc/issue
    echo "FluxLinux ${LATEST_VERSION} \n \l
" | sudo tee /etc/issue

    # Update /usr/lib/os-release
    if ! [ "/etc/os-release" -ef "/usr/lib/os-release" ]; then
        sudo cp /etc/os-release /usr/lib/os-release
    else
        print_warn "/etc/os-release is linked to /usr/lib/os-release, skipping copy."
    fi
}

function main() {
    print_ok "Current version is: ${CURRENT_VERSION}. Checking for updates..."

    # Ensure the current OS is FluxLinux
    ensureCurrentOsFluxLinux

    # Compare current version with latest version
    if [ "$CURRENT_VERSION" == "$LATEST_VERSION" ]; then
        print_ok "Your system is already up to date. No update available."
        exit 0
    fi

    print_ok "This script will upgrade your system to version ${LATEST_VERSION}..."
    print_ok "Please press CTRL+C to cancel... Countdown will start in 5 seconds..."
    sleep 5

    # Run necessary upgrades based on current version
    case "$CURRENT_VERSION" in
          "1.5.0")
              print_ok "Your system is already up to date. No update available."
              exit 0
              ;;
           *)
              print_error "Unknown current version. Exiting."
              exit 1
              ;;
    esac

    # Grammar sample:
    # case "$CURRENT_VERSION" in
    #     "1.0.2")
    #         upgrade_102_to_103
    #         upgrade_103_to_104
    #         ;;
    #     "1.0.3")
    #         upgrade_103_to_104
    #         ;;
    #     "1.0.4")
    #         print_ok "Your system is already up to date. No update available."
    #         exit 0
    #         ;;
    #     *)
    #         print_error "Unknown current version. Exiting."
    #         exit 1
    #         ;;
    # esac

    # Apply updates to lsb-release, os-release, and issue files
    applyLsbRelease
    print_ok "System upgraded successfully to version ${LATEST_VERSION}"
}

main