#!/bin/bash
L=/mnt/lfs
mountpoint -q $L || { echo "sda2 belum ter-mount"; exit 1; }
CH="chroot $L /usr/bin/env -i PATH=/usr/sbin:/usr/bin /bin/bash -c"
RF=$L/root/.config/fastfetch
[ -f $RF/cube.txt ] && [ -f $RF/config.jsonc ] || { echo "cube.txt/config.jsonc root tidak ditemukan"; exit 1; }

# --- fastfetch: salin logo + config milik root ke lokasi yang terbaca semua user ---
install -D -m 644 $RF/cube.txt $L/usr/share/webforge/logo.txt
mkdir -p $L/etc/xdg/fastfetch $L/etc/skel/.config/fastfetch
sed 's|"/root/.config/fastfetch/cube.txt"|"/usr/share/webforge/logo.txt"|' $RF/config.jsonc > $L/etc/xdg/fastfetch/config.jsonc
cp $L/etc/xdg/fastfetch/config.jsonc $L/etc/skel/.config/fastfetch/config.jsonc
chmod -R a+rX $L/usr/share/webforge $L/etc/xdg/fastfetch $L/etc/skel
chmod 755 $L/etc/skel/.config $L/etc/skel/.config/fastfetch
chmod 644 $L/etc/profile.d/webforge.sh

# --- shell user biasa (tidak menimpa .bashrc milikmu) ---
grep -q 'profile.d' $L/etc/profile || cat >> $L/etc/profile <<'EOF'

for s in /etc/profile.d/*.sh; do [ -r "$s" ] && . "$s"; done
unset s
EOF
[ -f $L/etc/skel/.bash_profile ] || echo '[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"' > $L/etc/skel/.bash_profile
grep -q 'usr/sbin' $L/etc/profile.d/webforge.sh || echo 'case ":$PATH:" in *:/usr/sbin:*) ;; *) export PATH="$PATH:/usr/sbin" ;; esac' >> $L/etc/profile.d/webforge.sh

# --- sudo ---
$CH 'grep -q "^wheel:" /etc/group || groupadd wheel'
chmod 4755 $L/usr/bin/sudo
mkdir -p $L/etc/sudoers.d
cat > $L/etc/sudoers.d/10-wheel <<'EOF'
%wheel ALL=(ALL:ALL) ALL
Defaults secure_path="/usr/sbin:/usr/bin"
EOF
chmod 0440 $L/etc/sudoers.d/10-wheel
grep -qE '^[#@]includedir[[:space:]]+/etc/sudoers.d' $L/etc/sudoers || echo '@includedir /etc/sudoers.d' >> $L/etc/sudoers
if [ ! -f $L/etc/pam.d/sudo ]; then
  mkdir -p $L/etc/pam.d
  if [ -f $L/etc/pam.d/system-auth ]; then
    printf '%s\n' 'auth      include     system-auth' 'account   include     system-account' \
      'session   required    pam_env.so' 'session   include     system-session' > $L/etc/pam.d/sudo
  else
    printf '%s\n' 'auth      required    pam_unix.so' 'account   required    pam_unix.so' \
      'session   required    pam_unix.so' > $L/etc/pam.d/sudo
  fi
  echo "[fix] /etc/pam.d/sudo dibuat"
fi

echo; echo "======== CEK ========"
ls -l $L/usr/share/webforge/logo.txt $L/etc/xdg/fastfetch/config.jsonc $L/etc/skel/.config/fastfetch/config.jsonc
grep -n '"source"' $L/etc/xdg/fastfetch/config.jsonc
$CH 'visudo -c; sudo -V | grep -iE "version|pam"; echo "-- pam.d:"; ls /etc/pam.d; echo "-- pam.d/other:"; cat /etc/pam.d/other; echo "-- pam.d/sudo:"; cat /etc/pam.d/sudo' || true
echo "[selesai] fix-image"
