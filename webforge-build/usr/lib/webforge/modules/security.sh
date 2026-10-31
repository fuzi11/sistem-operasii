#!/usr/bin/env bash

handle_security() {
  local action="$1"
  local sub="$2"
  local param="$3"

  case "$action" in
    audit)
      echo "=== AUDIT KEAMANAN SISTEM ==="
      echo "[*] Akun dengan hak akses UID 0 (Root):"
      awk -F: '($3 == 0) {print " - " $1}' /etc/passwd
      echo "[*] Status Firewall (nftables):"
      systemctl is-active --quiet nftables && echo " [✔] Aktif" || echo " [✘] Mati"
      echo "[*] Versi OS & Kernel:"
      uname -r
      ;;
    harden)
      echo "[+] Menerapkan pengaturan hardening standar..."
      chmod 700 /root
      chmod 600 /etc/shadow 2>/dev/null || true
      echo "[+] Hardening dasar selesai diterapkan."
      ;;
    perms)
      [ -z "$sub" ] && { echo "Gunakan: webforge perms <domain>"; exit 1; }
      echo "[+] Memperbaiki kepemilikan & izin webroot /var/www/$sub..."
      chown -R www-data:www-data "/var/www/$sub" 2>/dev/null || echo "[-] Webroot tidak ditemukan."
      find "/var/www/$sub" -type d -exec chmod 755 {} \; 2>/dev/null || true
      find "/var/www/$sub" -type f -exec chmod 644 {} \; 2>/dev/null || true
      echo "[+] Izin file berhasil diperbaiki ke www-data:www-data."
      ;;
    ssh)
      case "$sub" in
        status)
          echo "=== STATUS LAYANAN SSH ==="
          systemctl status sshd --no-pager 2>/dev/null || systemctl status ssh --no-pager
          echo ""
          grep -E "^Port" /etc/ssh/sshd_config 2>/dev/null || echo "Port: 22 (Default)"
          ;;
        addkey)
          [ -z "$param" ] && { echo "Gunakan: webforge ssh addkey <user>"; exit 1; }
          echo "[i] Masukkan SSH Public Key untuk user $param:"
          read -r pubkey
          local home_dir
          home_dir=$(eval echo "~$param")
          mkdir -p "$home_dir/.ssh"
          echo "$pubkey" >> "$home_dir/.ssh/authorized_keys"
          chmod 700 "$home_dir/.ssh"
          chmod 600 "$home_dir/.ssh/authorized_keys"
          chown -R "$param:$param" "$home_dir/.ssh"
          echo "[+] Kunci publik berhasil ditambahkan untuk $param."
          ;;
        port)
          [ -z "$param" ] && { echo "Gunakan: webforge ssh port <nomor>"; exit 1; }
          sed -i "s/^#\?Port .*/Port $param/" /etc/ssh/sshd_config
          systemctl restart sshd 2>/dev/null || systemctl restart ssh
          echo "[+] Port SSH berhasil diubah ke $param."
          ;;
        *)
          echo "Gunakan: webforge ssh status | addkey <user> | port <nomor>"
          ;;
      esac
      ;;
    user)
      case "$sub" in
        add)
          [ -z "$param" ] && { echo "Gunakan: webforge user add <nama>"; exit 1; }
          useradd -m -s /bin/bash "$param"
          passwd "$param"
          usermod -aG wheel,sudo "$param" 2>/dev/null || true
          echo "[+] User admin $param berhasil dibuat."
          ;;
        remove)
          [ -z "$param" ] && { echo "Gunakan: webforge user remove <nama>"; exit 1; }
          userdel -r "$param"
          echo "[+] User $param berhasil dihapus."
          ;;
        list)
          echo "=== DAFTAR USER ADMIN (Grup Wheel / Sudo) ==="
          getent group wheel 2>/dev/null || getent group sudo
          ;;
        lock)
          [ -z "$param" ] && { echo "Gunakan: webforge user lock <nama>"; exit 1; }
          passwd -l "$param"
          echo "[+] Akun user $param dikunci."
          ;;
        unlock)
          [ -z "$param" ] && { echo "Gunakan: webforge user unlock <nama>"; exit 1; }
          passwd -u "$param"
          echo "[+] Akun user $param dibuka kuncinya."
          ;;
        *)
          echo "Gunakan: webforge user add|remove|list|lock|unlock <nama>"
          ;;
      esac
      ;;
    logins)
      echo "=== RIWAYAT LOGIN TERAKHIR ==="
      last -n 10
      echo ""
      echo "=== LASTLOG / PERCOBAAN LOGIN ==="
      lastlog | grep -v "Never"
      ;;
    headers)
      [ -z "$sub" ] && { echo "Gunakan: webforge headers <domain>"; exit 1; }
      echo "=== TES HEADER KEAMANAN: $sub ==="
      curl -I -s "http://$sub"
      ;;
    *)
      echo "Perintah Keamanan tidak dikenal. Ketik 'webforge help'."
      ;;
  esac
}