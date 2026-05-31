#!/bin/bash
DIR="single_rootfs"
mkdir -p $DIR/{bin,dev,proc,sys,etc,tmp,root}

echo "=> Mendownload dan setup BusyBox..."
wget -nc https://busybox.net/downloads/binaries/1.35.0-x86_64-linux-musl/busybox
chmod +x busybox
cp busybox $DIR/bin/
cd $DIR/bin
./busybox --install -s .
cd ../../

# Membuat script init agar OS bisa booting
cat << 'EOF' > $DIR/init
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev

# Setup Network (untuk soal no 8)
ip link set up dev lo
udhcpc -i eth0

exec /bin/sh
EOF
chmod +x $DIR/init

echo "=> Membungkus filesystem ke single.gz..."
cd $DIR
find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../osboot/single.gz
cd ..
rm -rf $DIR # Hapus sisa build
echo "=> Selesai! output di osboot/single.gz"
