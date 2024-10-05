#!/bin/bash
# A script to build LFS.
# Written as instructions were followed from https://www.linuxfromscratch.org/lfs/view/stable-systemd/index.html
#
# log_info commands are both intended as progress indicators during the installation process and documentation/commentary within the script.

#========================================
# VARIABLES
#========================================

LFSDIR="lfs"
LFS=$LFSDIR
export LFS $LFS

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#========================================
# FUNCTIONS
#========================================

set_global_access_permissions() {
    local folder="$1"

    if [ -z "$folder" ]; then
        echo "Usage: set_global_access_permissions <folder_path>"
        return 1
    fi

    if [ ! -d "$folder" ]; then
        echo "Error: $folder is not a valid directory"
        return 1
    fi

    # Set permissions for the folder itself
    chmod 755 "$folder"

    # Set permissions for all contents within the folder
    find "$folder" -type d -exec chmod 755 {} +
    find "$folder" -type f -exec chmod 644 {} +

    # Make all .sh files executable
    find "$folder" -type f -name "*.sh" -exec chmod +x {} +

    echo "Permissions set successfully for $folder and its contents"
    echo "All users can now access the folder, and all .sh files are executable"
}

run_as_user() {
USER=$1
SCRIPT=$2

MAKEOUTPUT=$(su $USER << EOF
source ~/.bashrc
if [ -f "$SCRIPT" ]; then
    echo "$SCRIPT found"
    $SCRIPT
else
    echo "ERROR: $SCRIPT not found in $SCRIPT_DIR"
    exit 1
fi
EOF
)

# Get the exit status of the su command
EXITSTATUS=$?

# Display the captured output
echo "Output from $SCRIPT:"
echo "$MAKEOUTPUT"
}

#========================================
# CONSTRUCTION
#========================================

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   printf "INFO::\tThis script must be run as root.\n"
   RUN_AS_ROOT=false
   exit 1
else
   RUN_AS_ROOT=true
fi

printf "INFO:\tMaking all scripts executable in current dir\n"
chmod +x *.sh

printf "INFO:\tVerify that host has required prerequisites for LFS construction...\n"
./checkHost.sh
if [ $? -ne 0 ]; then
    printf "INFO:\tHost does not meet all prerequisites for LFS. Installation aborted.\n"
    exit 1
fi
printf "INFO:\tHost meets all prerequisites for LFS. Proceeding with installation.\n"

printf "INFO:\tSetting up directory structure for LFS installation...\n"
./setupPartitions.sh $LFSDIR
if [ ! -d "$LFSDIR" ]; then
    printf "INFO:\t$LFSDIR does not exist. Failed to setup directory structure.\n"
    exit 1
fi
printf "INFO:\tFinished setting up LFS directory structure.\n"

printf "INFO:\tDownloading packages required for LFS\n"
./downloadLFS.sh
if [ $? -ne 0 ]; then
    printf "INFO:\tLFS download script failed\n"
    exit 1
fi
printf "INFO:\tDownloaded all required packages for LFS installation.\n"

printf "INFO:\tSetting up directory structure.\n"
./setupDirs.sh
printf "INFO:\tFinished setting up the directory structure.\n"

printf "INFO:\tAdding LFS group and user.\n"
./addLFSUser.sh
printf "INFO:\tFinished adding lfs.\n"

printf "INFO:\tSetting up lfs user env.\n"
su lfs -c "./configLFSUser.sh"
printf "INFO:\tFinished setting up lfs user env.\n"

printf "INFO:\tMaking lfs packages.\n"
printf "INFO:\tThis will take a while.\n"

# Ensure access permissions prior to beginning builds
#set_global_access_permissions $SCRIPT_DIR
chown -R lfs:lfs lfs
# Run the local script as the target user with login shell environment
run_as_user lfs "./makePackages.sh"

# Check the exit status of the local script
if [[ $EXITSTATUS -eq 0 ]]; then
    printf "INFO:\tFinished making lfs packages.\n"
else
    printf "ERROR:\tFailed making lfs packages. Exit status: %d\n" "$EXITSTATUS"
    exit 1
fi