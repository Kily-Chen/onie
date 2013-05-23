#!/bin/sh

cd $(dirname $0)

[ -r ./machine.conf ] || {
    echo "ERROR: ONIE update machine.conf file is missing."
    exit 1
}
. ./machine.conf

# get running machine from conf file
[ -r /etc/machine.conf ] && . /etc/machine.conf

fail=
if [ "$onie_machine" != "$image_machine" ] ; then
    fail=yes
fi
if [ "$onie_arch" != "$image_arch" ] ; then
    fail=yes
fi

if [ "$fail" = "yes" ] && [ -z "$force" ] ; then
    echo "ERROR: Machine mismatch"
    echo "Running machine     : ${onie_arch}/$onie_machine"
    echo "Update Image machine: ${image_arch}/$image_machine"
    echo "Source URL: $onie_exec_url"
    exit 1
fi

[ -r onie-update.tar.xz ] || {
    echo "ERROR: ONIE update tar file is missing."
    exit 1
}

echo "ONIE: Version     : $image_version"
echo "ONIE: Architecture: $image_arch"
echo "ONIE: Machine     : $image_machine"

xz -d -c onie-update.tar.xz | tar -xf -

# install ONIE
echo "Updating ONIE kernel ..."
flashcp -v ONIE.bin /dev/mtd-onie || {
    echo "ERROR: Updating ONIE kernel failed."
    exit 1
}

# install u-boot
echo "Updating ONIE U-Boot ..."
flashcp -v u-boot.bin /dev/mtd-uboot || {
    echo "ERROR: Updating ONIE U-Boot failed."
    exit 1
}

echo "Rebooting..."
reboot
