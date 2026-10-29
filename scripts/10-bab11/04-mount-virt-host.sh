#!/bin/bash
# Skrip untuk mount virtual filesystem LFS dari sistem HOST (Section 11.5.2.1)

function mountbind {
   if ! mountpoint "$LFS/$1" >/dev/null 2>&1; then
     $SUDO mount --bind "/$1" "$LFS/$1"
     echo "[+] $LFS/$1 mounted"
   else
     echo "[i] $LFS/$1 already mounted"
   fi
}

function mounttype {
   if ! mountpoint "$LFS/$1" >/dev/null 2>&1; then
     $SUDO mount -t "$2" "$3" "$4" "$5" "$LFS/$1"
     echo "[+] $LFS/$1 mounted"
   else
     echo "[i] $LFS/$1 already mounted"
   fi
}

if [ $EUID -ne 0 ]; then
  SUDO="sudo"
else
  SUDO=""
fi

if [ -z "$LFS" ]; then
  export LFS="/mnt/lfs"
  echo "[i] Variabel \$LFS belum diatur. Menggunakan default: $LFS"
fi

mountbind dev
mounttype dev/pts devpts devpts -o gid=5,mode=620
mounttype proc    proc   proc
mounttype sys     sysfs  sysfs
mounttype run     tmpfs  run

if [ -h "$LFS/dev/shm" ]; then
  $SUDO install -v -d -m 1777 "$LFS$(realpath /dev/shm)"
else
  mounttype dev/shm tmpfs tmpfs -o nosuid,nodev
fi

# Hapus tanda komentar jika direktori berikut di-mount di partisi terpisah pada host:
#mountbind usr/src
#mountbind boot
#mountbind home

echo "=== Virtual Filesystem LFS Siap Digunakan ==="