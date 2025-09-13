#!/bin/bash

set -ouex pipefail

# Modify existing repos to add excludes instead of replacing them

# Install dnf config manager
dnf install -y 'dnf-command(config-manager)'

# Add exclude packages to existing repositories
EXCLUDE_PACKAGES="kpatch,kpatch-dnf,almalinux-release,system-release,anaconda,anaconda-gui,anaconda-core,anaconda-tui,anaconda-widgets,almalinux-indexhtml,almalinux-bookmarks,firefox,anaconda-live"

# Function to add excludes to repo files
add_excludes_to_repo() {
	local repo_file="$1"
	local repo_section="$2"

	if [ -f "$repo_file" ]; then
		# Check if exclude line already exists in this section
		if ! sed -n "/\[$repo_section\]/,/^\[/p" "$repo_file" | grep -q "^exclude="; then
			# Add exclude line after the section header
			sed -i "/\[$repo_section\]/a exclude=$EXCLUDE_PACKAGES" "$repo_file"
		fi
	fi
}

# Add excludes to existing AlmaLinux repositories
# Handle different possible repo file names
for repo_file in /etc/yum.repos.d/almalinux*.repo; do
	if [ -f "$repo_file" ]; then
		# Add excludes to common sections
		for section in appstream baseos crb extras devel; do
			add_excludes_to_repo "$repo_file" "$section"
		done
	fi
done

# Also check for standard repo names
add_excludes_to_repo "/etc/yum.repos.d/almalinux-appstream.repo" "appstream"
add_excludes_to_repo "/etc/yum.repos.d/almalinux-baseos.repo" "baseos"
add_excludes_to_repo "/etc/yum.repos.d/almalinux-crb.repo" "crb"
add_excludes_to_repo "/etc/yum.repos.d/almalinux-extras.repo" "extras"

# Enable CRB repository
dnf config-manager --set-enabled crb

# Clean cache
dnf clean all
rm -rf /var/cache/dnf

# Add new Oreon-specific repositories
cat <<EOF >/etc/yum.repos.d/oreon.repo
[oreon]
name=oreon
baseurl=https://download.copr.fedorainfracloud.org/results/brandonlester/oreon-10/centos-stream-10-\$basearch/
gpgcheck=1
gpgkey=https://download.copr.fedorainfracloud.org/results/brandonlester/oreon-10/pubkey.gpg
repo_gpgcheck=0
enabled=1

[backports]
name=backports
baseurl=https://download.copr.fedorainfracloud.org/results/brandonlester/oreon-10-backports/centos-stream-9-\$basearch/
gpgcheck=1
gpgkey=https://download.copr.fedorainfracloud.org/results/brandonlester/oreon-10-backports/pubkey.gpg
repo_gpgcheck=0
enabled=1
EOF

# Install EPEL release (this will create the proper EPEL repo file)
dnf install -y epel-release

# Install packages (remove unwanted, install wanted)

dnf shell -y --setopt protected_packages= <<EOI
swap almalinux-release oreon-release
swap almalinux-repos oreon-repos
run
install @workstation-product-environment @hardware-support @multimedia @core @standard @gnome-desktop glib2
run
swap almalinux-logos oreon-logos
swap almalinux-backgrounds oreon-backgrounds
run
install gnome-shell-extension-dash-to-panel-oreon gnome-shell-extension-arc-menu-oreon gnome-shell-extension-blur-my-shell-oreon gnome-shell-extension-desktop-icons gnome-shell-oreon-theming oreon-shell-theme kernel-devel python3-crypt-r memtest86+ fuse xdg-utils atheros-firmware
EOI

rpm -qa | sort | grep -v "almalinux|oreon"

echo "Configuration complete."

systemctl enable podman.socket
