#!/bin/bash
# A script to build LFS.
# Written as instructions were followed from https://www.linuxfromscratch.org/lfs/view/stable-systemd/index.html
#
# log_info commands are both intended as progress indicators during the installation process and documentation/commentary within the script.

#========================================
# VARIABLES
#========================================

LFSDIR="build"
LFS=$LFSDIR
export LFS $LFS
printf "INFO:\tStarting...\n"

#========================================
# FUNCTIONS
#========================================


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