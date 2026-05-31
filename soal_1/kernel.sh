#!/bin/bash
echo "=> Mendownload Kernel Linux 6.1.1..."
wget -nc https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.1.1.tar.xz
tar -xf linux-6.1.1.tar.xz
cd linux-6.1.1

echo "=> Konfigurasi Kernel..."
make defconfig

# Mengaktifkan fitur yang diminta soal
scripts/config --enable CONFIG_FUSE_FS
scripts/config --enable CONFIG_E1000
scripts/config --enable CONFIG_NET_CORE

# FIX ERROR: Mematikan sertifikat kunci yang sering bikin error di Debian/Kali/Ubuntu
scripts/config --disable CONFIG_SYSTEM_TRUSTED_KEYS
scripts/config --disable CONFIG_SYSTEM_REVOCATION_KEYS
scripts/config --disable CONFIG_DEBUG_INFO

make olddefconfig

echo "=> Mengkompilasi Kernel (Maksimal 2 Core agar WSL tidak memori penuh)..."
# Menggunakan 2 core saja agar aman. Kalau RAM-mu besar (16GB+), bisa diganti jadi -j4
make -j2 bzImage

echo "=> Memindahkan bzImage ke osboot..."
# Pengecekan agar tidak bohong kalau file gagal dibuat
if [ -f arch/x86/boot/bzImage ]; then
    cp arch/x86/boot/bzImage ../osboot/
    echo "=> Selesai! bzImage berhasil dibuat di osboot/bzImage"
else
    echo "=> GAGAL! File bzImage tidak ditemukan. Coba cek error di atas."
fi

cd ..
