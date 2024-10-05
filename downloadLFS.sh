#!/bin/bash

# Function to log errors
log_error() {
    echo "Error: $1" >&2
}

# Function to log info
log_info() {
    echo "Info: $1"
}

# Function to log warnings
log_warning() {
    echo "Warning: $1" >&2
}

# Ensure LFS environment variable is set
if [ -z "$LFS" ]; then
    log_error "LFS environment variable is not set."
    exit 1
fi

# Create the sources directory if it doesn't exist
mkdir -p $LFS/sources || { log_error "Failed to create $LFS/sources directory."; exit 2; }

# Download the md5sums file
wget https://www.linuxfromscratch.org/lfs/view/stable-systemd/md5sums -O $LFS/sources/md5sums || { log_error "Failed to download md5sums."; exit 3; }

# Download the wget-list-systemd
wget https://www.linuxfromscratch.org/lfs/view/stable-systemd/wget-list-systemd -O $LFS/sources/wget-list-systemd || { log_error "Failed to download wget-list-systemd."; exit 4; }

# Change to the sources directory
cd $LFS/sources || { log_error "Failed to change to $LFS/sources directory."; exit 5; }

# Read wget-list-systemd and check/download each file
while read -r url; do
    filename=$(basename "$url")
    if [ -f "$filename" ]; then
        # File exists, check its MD5
        if md5sum -c --quiet <(grep "$filename" md5sums); then
            log_info "File $filename already exists and is valid. Skipping download."
            continue
        else
            log_info "File $filename exists but is invalid. Re-downloading."
        fi
    fi
    
    # Download the file
    wget --continue "$url" || { log_error "Failed to download $filename"; exit 6; }
done < wget-list-systemd

# Verify all downloaded packages
if ! md5sum -c md5sums; then
    log_error "MD5 verification failed for one or more packages."
    exit 7
fi

# Set ownership of the files to root if running as root
if [[ $EUID -ne 0 ]]; then
    chown root:root * || { log_error "Failed to change ownership of files."; exit 8; }
    log_info "File ownership set to root:root."
else
    log_warning "Skipped changing file ownership as script is not running as root."
fi

log_info "Download and verification complete."
exit 0