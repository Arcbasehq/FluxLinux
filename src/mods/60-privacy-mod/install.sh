#!/bin/bash
set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

echo "Applying privacy and security hardening..."

export DEBIAN_FRONTEND=noninteractive

# 1. Install security packages
apt-get update
apt-get install -y --no-install-recommends \
    apparmor \
    apparmor-profiles \
    apparmor-utils \
    ufw \
    fail2ban \
    libpam-pwquality \
    libpam-tmpdir \
    unhide \
    macchanger

# 2. Kernel Hardening (sysctl)
cat << 'EOF' > /etc/sysctl.d/99-security.conf
# Network Security
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.tcp_rfc1337 = 1
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1

# Kernel parameters
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.sysrq = 0
kernel.core_uses_pid = 1
kernel.randomize_va_space = 2
kernel.yama.ptrace_scope = 2
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
fs.protected_fifos = 2
fs.protected_regular = 2
fs.suid_dumpable = 0
net.core.bpf_jit_harden = 2
EOF

# 3. Disable unused kernel modules
cat << 'EOF' > /etc/modprobe.d/security-blacklist.conf
# Filesystems
install cramfs /bin/true
install freevxfs /bin/true
install jffs2 /bin/true
install hfs /bin/true
install hfsplus /bin/true

# Network protocols
install dccp /bin/true
install sctp /bin/true
install rds /bin/true
install tipc /bin/true

# Firewire
install firewire-core /bin/true
install firewire-ohci /bin/true
install firewire-sbp2 /bin/true
EOF

# 4. Disable core dumps
cat << 'EOF' > /etc/security/limits.d/99-disable-core.conf
* hard core 0
EOF

# 5. UFW Firewall Setup
ufw default deny incoming
ufw default allow outgoing
sed -i 's/IPV6=yes/IPV6=no/g' /etc/default/ufw
systemctl enable ufw || true

# 6. Enable AppArmor
systemctl enable apparmor || true

# 7. MAC Spoofing via NetworkManager
mkdir -p /etc/NetworkManager/conf.d/
cat << 'EOF' > /etc/NetworkManager/conf.d/mac-randomization.conf
[device]
wifi.scan-rand-mac-address=yes

[connection]
wifi.cloned-mac-address=random
ethernet.cloned-mac-address=random
EOF

# 8. Clean up
apt-get clean

echo "Privacy and security hardening complete."
