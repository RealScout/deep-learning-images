#!/bin/bash -e

# disable unattended upgrades that run on boot since 16.04, resulting in:
#   amazon-ebs: E: Could not get lock /var/lib/dpkg/lock - open (11: Resource temporarily unavailable)
#   amazon-ebs: E: Could not get lock /var/lib/apt/lists/lock - open (11: Resource temporarily unavailable)
#
# see also https://github.com/boxcutter/ubuntu/pull/73

. /etc/lsb-release

if [[ ${DISTRIB_RELEASE} == "16.04" ]]; then
    sudo sh -c 'cat << EOF > /etc/apt/apt.conf.d/51disable-unattended-upgrades
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Unattended-Upgrade "0";
EOF
'
fi
