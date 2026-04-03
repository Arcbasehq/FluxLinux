#!/usr/bin/env bash
set -e                # exit on error
set -o pipefail       # exit on pipeline error
set -u                # treat unset variable as error

if [ "$LIBREWOLF_PROVIDER" == "none" ]; then
    print_ok "We don't need to install LibreWolf, please check the config file"
elif [ "$LIBREWOLF_PROVIDER" == "deb" ]; then
    print_ok "Adding LibreWolf APT repository"
    wait_network
    apt install $INTERACTIVE software-properties-common wget gnupg -y

    print_ok "Adding LibreWolf GPG key..."
    wget -qO- https://deb.librewolf.net/keyring.gpg | gpg --dearmor | tee /usr/share/keyrings/librewolf-archive.gpg > /dev/null

    print_ok "Adding LibreWolf repository to sources list..."
    echo "deb [signed-by=/usr/share/keyrings/librewolf-archive.gpg] https://deb.librewolf.net $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/librewolf.list

    if [ -n "$BUILD_LIBREWOLF_MIRROR" ]; then
        print_ok "Replacing deb.librewolf.net with build mirror: $BUILD_LIBREWOLF_MIRROR"
        sed -i "s|deb.librewolf.net|$BUILD_LIBREWOLF_MIRROR|g" /etc/apt/sources.list.d/librewolf.list
    fi

    print_ok "Updating package list..."
    apt update
    judge "Update package list"

    print_ok "Installing LibreWolf and locale package $LIBREWOLF_LOCALE_PACKAGE"
    apt install $INTERACTIVE librewolf $LIBREWOLF_LOCALE_PACKAGE --no-install-recommends
    judge "Install LibreWolf"

    if [ -n "$BUILD_LIBREWOLF_MIRROR" ] && [ -n "$LIVE_LIBREWOLF_MIRROR" ]; then
        print_ok "Replacing build mirror $BUILD_LIBREWOLF_MIRROR with live mirror $LIVE_LIBREWOLF_MIRROR..."
        sed -i "s/$BUILD_LIBREWOLF_MIRROR/$LIVE_LIBREWOLF_MIRROR/g" /etc/apt/sources.list.d/librewolf.list
        judge "Replace build mirror with live mirror"
    elif [ -n "$LIVE_LIBREWOLF_MIRROR" ]; then
        print_ok "Replacing deb.librewolf.net with live mirror $LIVE_LIBREWOLF_MIRROR..."
        sed -i "s|deb.librewolf.net|$LIVE_LIBREWOLF_MIRROR|g" /etc/apt/sources.list.d/librewolf.list
        judge "Replace official URL with live mirror"
    else
        print_warn "No mirrors set, skipping mirror replacement"
    fi
elif [ "$LIBREWOLF_PROVIDER" == "flatpak" ]; then
    print_ok "Installing LibreWolf from Flathub..."
    flatpak install -y flathub io.gitlab.librewolf-community
    judge "Install LibreWolf from Flathub"
else
    print_error "Unknown LibreWolf provider: $LIBREWOLF_PROVIDER"
    print_error "Please check the config file"
    exit 1
fi