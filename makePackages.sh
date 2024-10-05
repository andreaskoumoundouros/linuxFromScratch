#!/bin/bash

# Function to extract tar files (.tar.xz or .tar.gz)
extract() {
    local file="$1"
    local output_dir="$2"

    # Ensure the output directory exists
    mkdir -p "$output_dir"

    if [[ -z "$file" || -z "$output_dir" ]]; then
        echo "Usage: extract <file> <output_dir>"
        return 1
    fi

    case "$file" in
        *.tar.gz | *.tgz)
            tar -xzf "$file" -C "$output_dir"
            ;;
        *.tar.xz)
            tar -xJf "$file" -C "$output_dir"
            ;;
        *.tar)
            tar -xf "$file" -C "$output_dir"
            ;;
        *.gz)
            gunzip -c "$file" > "$output_dir/$(basename "$file" .gz)"
            ;;
        *.xz)
            unxz -c "$file" > "$output_dir/$(basename "$file" .xz)"
            ;;
        *)
            echo "Unsupported file type: $file"
            return 1
            ;;
    esac

    echo "Extracted $file to $output_dir"

    return 0
}


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
    echo "LFS environment variable is not set."
    exit 1
fi

LFS=$(realpath $LFS)
SOURCEDIR=$(realpath $LFS/sources)

# Build binutils
BINUTILS_BUILD_DIR=$SOURCEDIR/build/binutils-2.43.1
extract $SOURCEDIR/binutils-2.43.1.tar.xz $SOURCEDIR/build
cd $BINUTILS_BUILD_DIR
./configure --prefix=$LFS/tools \
             --with-sysroot=$LFS \
             --target=$LFS_TGT   \
             --disable-nls       \
             --enable-gprofng=no \
             --disable-werror    \
             --enable-new-dtags  \
             --enable-default-hash-style=gnu

make
make install
cd $LFS

exit 0