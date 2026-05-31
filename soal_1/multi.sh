#!/bin/bash
echo "=> Membersihkan sisa error lama..."
rm -rf multi_rootfs osboot/multi.gz
DIR="multi_rootfs"

# Buat kerangka folder
mkdir -p $DIR/{bin,sbin,dev,proc,sys,etc,tmp,root,home/henn,home/hann,home/viii,home/kids}

echo "=> Download ulang BusyBox..."
wget -qO $DIR/bin/busybox https://busybox.net/downloads/binaries/1.35.0-x86_64-linux-musl/busybox
chmod +x $DIR/bin/busybox

echo "=> Membuat symlink krusial secara manual..."
# Ini agar kernel tidak kebingungan mencari /bin/sh dan /bin/login
cd $DIR/bin
ln -s busybox sh
ln -s busybox login
cd ../../

# ==== SETUP USER, GROUP, & PERMISSIONS ====
cat << 'EOF' > $DIR/etc/passwd
root:x:0:0:root:/root:/bin/sh
henn:x:1000:1000:henn:/home/henn:/bin/sh
hann:x:1001:1001:hann:/home/hann:/bin/sh
viii:x:1002:1002:viii:/home/viii:/bin/sh
kids:x:1003:1003:kids:/home/kids:/bin/sh
EOF

cat << 'EOF' > $DIR/etc/group
root:x:0:
henn:x:1000:
hann:x:1001:henn
viii:x:1002:henn,hann
kids:x:1003:henn,hann,viii
EOF

# Membuat enkripsi MD5 asli untuk setiap password
ROOT_HASH=$(openssl passwd -1 root123)
HENN_HASH=$(openssl passwd -1 henn123)
HANN_HASH=$(openssl passwd -1 hann123)
VIII_HASH=$(openssl passwd -1 viii123)
KIDS_HASH=$(openssl passwd -1 kids123)

cat << EOF > $DIR/etc/shadow
root:${ROOT_HASH}:19000:0:99999:7:::
henn:${HENN_HASH}:19000:0:99999:7:::
hann:${HANN_HASH}:19000:0:99999:7:::
viii:${VIII_HASH}:19000:0:99999:7:::
kids:${KIDS_HASH}:19000:0:99999:7:::
EOF

# Linux mewajibkan file shadow bersifat sangat rahasia
chmod 600 $DIR/etc/shadow

chmod 700 $DIR/root
chmod 777 $DIR/tmp
chmod 700 $DIR/home/henn
chown 1000:1000 $DIR/home/henn
chmod 770 $DIR/home/hann
chown 1001:1001 $DIR/home/hann
chmod 770 $DIR/home/viii
chown 1002:1002 $DIR/home/viii
chmod 770 $DIR/home/kids
chown 1003:1003 $DIR/home/kids
chmod 755 $DIR/home

# ==== SETUP BANNER ====
cat << 'EOF' > $DIR/etc/issue
  ___                               _ _   ___         _         
 | __|_ _ _ _ _____ __ _____| | | | _ \__ _ _ _| |_ _  _ 
 | _/ _` | '_/ -_) V  V / -_) | | |  _/ _` | '_|  _| || |
 |_|\__,_|_| \___|\_/\_/\___|_|_| |_| \__,_|_|  \__|\_, |
                                                    |__/ 
EOF
cat << 'EOF' > $DIR/etc/profile
cat /etc/issue
echo "Welcome, $USER"
EOF

# ==== SETUP INIT SCRIPT ====
cat << 'INIT_EOF' > $DIR/init
#!/bin/sh
# 1. Minta BusyBox install semua symlink perintah dari DALAM Qemu!
/bin/busybox --install -s /bin

# 2. Mount virtual filesystem
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev

# 3. FUSE & Network
mknod /dev/fuse c 10 229
ip link set up dev lo
ip link set up dev eth0      # <-- INI TAMBAHANNYA: Menyalakan kartu jaringan
udhcpc -i eth0 &             # <-- INI TAMBAHANNYA: Tanda & agar dia jalan di background

# 4. Install Package Manager (Soal no 9)
if [ ! -f /bin/party ]; then
    wget -qO /tmp/apk-tools.tar.gz https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/apk-tools-static-2.14.0-r2.apk
    tar -xzf /tmp/apk-tools.tar.gz -C /tmp sbin/apk.static
    mv /tmp/sbin/apk.static /bin/party
    chmod +x /bin/party
fi

# 5. Jalankan layar login
while true; do
    setsid cttyhack /bin/login
done
INIT_EOF

# Pastikan init bisa dieksekusi!
chmod +x $DIR/init

echo "=> Membungkus ulang multi.gz..."
cd $DIR
find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../osboot/multi.gz
cd ..
echo "=> Selesai! Siap dicoba."
