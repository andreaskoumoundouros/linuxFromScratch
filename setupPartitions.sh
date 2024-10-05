#!/bin/bash
# Creates the standard "partition" structure for a LFS installation.

BUILDDIR=$1

mkdir -p $BUILDDIR
cd $BUILDDIR

mkdir -p boot
mkdir -p boot/efi
mkdir -p home
mkdir -p usr
mkdir -p opt
mkdir -p tmp
mkdir -p usr/src