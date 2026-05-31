#!/bin/bash

# Konfigurasi QEMU dasar (RAM 512M, aktifkan Network agar bisa ping/wget)
QEMU_CMD="qemu-system-x86_64 -m 512M -netdev user,id=n1 -device e1000,netdev=n1"

if [ "$1" == "--single" ]; then
    $QEMU_CMD -kernel osboot/bzImage -initrd osboot/single.gz -append "console=ttyS0" -nographic
elif [ "$1" == "--multi" ]; then
    $QEMU_CMD -kernel osboot/bzImage -initrd osboot/multi.gz -append "console=ttyS0" -nographic
elif [ "$1" == "--all" ]; then
    $QEMU_CMD -cdrom osboot/farewell.iso -nographic
else
    echo "Gunakan argumen: --single, --multi, atau --all"
fi
