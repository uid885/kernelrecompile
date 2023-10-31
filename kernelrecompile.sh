#!/bin/bash -
# Author:           Christo Deale                  
# Date  :           2023-10-31             
# kernelrecompile:  Utility to recompile kernel

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# Load necessary kernel development packages
dnf groupinstall "Development Tools" -y
dnf install kernel-devel kernel-headers -y

# Define kernel version to recompile
KERNEL_VERSION=$(uname -r)

# Set working directory for recompilation
WORKING_DIR=/usr/src/kernels/$KERNEL_VERSION

# Backup the original config file
cp $WORKING_DIR/.config $WORKING_DIR/.config.backup

# Load the current config for recompilation
zcat /proc/config.gz > $WORKING_DIR/.config

# Apply necessary patches for the kernel (if any)
# You can use 'patch' command to apply patches.

# Compile the kernel
make -C $WORKING_DIR clean
make -C $WORKING_DIR bzImage

# Install the new kernel
make -C $WORKING_DIR modules_install
make -C $WORKING_DIR install

# Configure GRUB to use the new kernel
grub2-mkconfig -o /boot/grub2/grub.cfg

# Reboot the system
reboot
