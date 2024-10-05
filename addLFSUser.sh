#!/bin/bash

check_user_exists() {
    local username="$1"
    if id "$username" &>/dev/null; then
        echo "User $username exists"
        return 0
    else
        echo "User $username does not exist"
        return 1
    fi
}

check_group_exists() {
    local groupname="$1"
    if getent group "$groupname" &>/dev/null; then
        echo "Group $groupname exists"
        return 0
    else
        echo "Group $groupname does not exist"
        return 1
    fi
}

create_user_and_group() {
    local username="$1"
    local groupname="$2"
    
    if ! check_group_exists "$groupname"; then
        groupadd "$groupname"
        echo "Group $groupname created"
    fi
    
    if ! check_user_exists "$username"; then
        useradd -s /bin/bash -g lfs -m -k /dev/null lfs
        echo "User $username created"
    fi
}

# Usage
USERNAME="lfs"
GROUPNAME="lfs"

create_user_and_group "$USERNAME" "$GROUPNAME"

chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}
case $(uname -m) in
  x86_64) chown -v lfs $LFS/lib64 ;;
esac