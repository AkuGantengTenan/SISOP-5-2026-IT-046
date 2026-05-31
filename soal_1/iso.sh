#!/bin/bash
echo "=> Membuat struktur ISO..."
mkdir -p iso/boot/grub

cp osboot/bzImage iso/boot/
cp osboot/single.gz iso/boot/
cp osboot/multi.gz iso/boot/

cat << 'EOF' > iso/boot/grub/grub.cfg
set timeout=5
set default=0

menuentry "OS Party - Single User" {
    linux /boot/bzImage console=ttyS0 console=tty0
    initrd /boot/single.gz
}

menuentry "OS Party - Multi User" {
    linux /boot/bzImage console=ttyS0 console=tty0
    initrd /boot/multi.gz
}
EOF

echo "=> Generate farewell.iso..."
grub-mkrescue -o osboot/farewell.iso iso/
rm -rf iso
echo "=> Selesai! ISO ada di osboot/farewell.iso"
