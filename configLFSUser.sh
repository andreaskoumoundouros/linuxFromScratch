#!/bin/bash

check_lfs_user() {
    if [[ "$(id -un)" != "lfs" ]]; then
        echo "This script must be run as the 'lfs' user."
        return 1
    else
        echo "Running as 'lfs' user. Proceeding..."
        return 0
    fi
}

# Check if the current user is 'lfs'
if ! check_lfs_user; then
    exit 1
fi

echo "exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash" > ~/.bash_profile

echo "set +h" > ~/.bashrc
echo "umask 022" >> ~/.bashrc
echo "LFS=$LFS" >> ~/.bashrc
echo "LC_ALL=POSIX" >> ~/.bashrc
echo "LFS_TGT=$(uname -m)-lfs-linux-gnu" >> ~/.bashrc
echo "PATH=/usr/bin" >> ~/.bashrc
echo "if [ ! -L /bin ]; then PATH=/bin:\$PATH; fi" >> ~/.bashrc
echo "PATH=$LFS/tools/bin:$PATH" >> ~/.bashrc
echo "CONFIG_SITE=$LFS/usr/share/config.site" >> ~/.bashrc
echo "export LFS LC_ALL LFS_TGT PATH CONFIG_SITE" >> ~/.bashrc
echo "export MAKEFLAGS=-j$(nproc)" >> ~/.bashrc

exit 0