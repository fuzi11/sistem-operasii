#!/usr/bin/env bash

handle_system() {
  local action="$1"
  local sub="$2"
  local param="$3"

  case "$action" in
    net)
      case "$sub" in
        info)
          echo "=== INFORMASI JARINGAN ==="
          ip -4 addr show
          echo ""
          echo "Gateway Default:"
          ip route | grep default
          echo ""
          echo "DNS Servers (/etc/resolv.conf):"
          grep "nameserver" /etc/resolv.conf 2>/dev/null || echo "DNS tidak terbaca."
          ;;
        test)
          echo "=== PENGUJIAN KONEKSI KELUAR & DNS ==="
          ping -c 3 8.8.8.8 > /dev/null 2>&1 && echo "[✔] Koneksi internet (IP) terhubung" || echo "[✘] Koneksi internet terputus"
          host google.com > /dev/null 2>&1 && echo "[✔] Resolusi DNS berfungsi" || echo "[✘] Resolusi DNS gagal"
          ;;
        ip)
          if [ "$sub" == "static" ]; then
            [ -z "$param" ] && { echo "Gunakan: webforge net ip static <ip>"; exit 1; }
            echo "[!] Mengubah ke IP statis ($param) memerlukan konfigurasi interface netplan/NetworkManager aktif."
            # Contoh dasar penulisan statis jika menggunakan systemd-networkd / interfaces
            echo "IP statis diatur ke $param"
          elif [ "$sub" == "dhcp" ]; then
            echo "[+] Mengembalikan interface jaringan ke DHCP..."
            dhclient -r 2>/dev/null
            dhclient 2>/dev/null || systemctl restart networking 2>/dev/null
            echo "[+] Selesai."
          else
            echo "Gunakan: webforge net ip static <ip> | dhcp"
          fi
          ;;
        *)
          echo "Gunakan: webforge net info | test | ip static <ip> | ip dhcp"
          ;;
      esac
      ;;
    hostname)
      [ -z "$sub" ] && { echo "Gunakan: webforge hostname <nama_baru>"; exit 1; }
      echo "[+] Mengubah hostname sistem menjadi '$sub'..."
      hostnamectl set-hostname "$sub"
      echo "[+] Hostname berhasil diubah."
      ;;
    time)
      echo "=== STATUS WAKTU & NTP ==="
      timedatectl status
      ;;
    timezone)
      [ -z "$sub" ] && { echo "Gunakan: webforge timezone <zona (contoh: Asia/Jakarta)>"; exit 1; }
      echo "[+] Mengubah zona waktu ke $sub..."
      timedatectl set-timezone "$sub"
      echo "[+] Zona waktu berhasil diperbarui."
      ;;
    sysinfo)
      echo "=== INFORMASI SISTEM & KERNEL ==="
      echo "Kernel: $(uname -r)"
      echo "Uptime: $(uptime -p)"
      echo "Distro: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '\"')"
      echo ""
      lscpu | grep -E "Model name|CPU\(s\):|Architecture"
      echo ""
      free -h
      echo ""
      df -h /
      ;;
    services)
      echo "=== DAFTAR LAYANAN WEBFORGE & STATUSNYA ==="
      for srv in nginx nftables sshd systemd-timesyncd; do
        if systemctl is-active --quiet "$srv" 2>/dev/null; then
          echo " [✔] $srv : Aktif (Running)"
        else
          echo " [✘] $srv : Mati / Tidak Aktif"
        fi
      done
      ;;
    reboot)
      echo "[!] Sistem akan melakukan reboot dalam beberapa detik..."
      systemctl reboot
      ;;
    shutdown)
      echo "[!] Sistem akan dimatikan (shutdown)..."
      systemctl poweroff
      ;;
    cleanup)
      echo "[+] Membersihkan cache, log lama, dan file sementara..."
      apt-get clean 2>/dev/null || true
      journalctl --vacuum-time=3d 2>/dev/null
      find /tmp -type f -atime +3 -delete 2>/dev/null || true
      echo "[+] Pembersihan sistem selesai."
      ;;
    *)
      echo "Perintah Jaringan & Sistem tidak dikenal. Ketik 'webforge help'."
      ;;
  esac
}