#!/usr/bin/env bash

handle_fw() {
  local action="$2"
  local target="$3"

  case "$action" in
    status)
      echo "=== STATUS ATURAN NFTABLES ==="
      nft list ruleset 2>/dev/null || echo "[-] nftables belum aktif atau service tidak berjalan."
      ;;
    allow)
      [ -z "$target" ] && { echo "Gunakan: webforge fw allow <port>"; exit 1; }
      nft add rule inet filter input tcp dport "$target" accept 2>/dev/null || \
      nft add rule ip filter input tcp dport "$target" accept 2>/dev/null
      echo "[+] Port $target berhasil dibuka (allow)."
      ;;
    deny)
      [ -z "$target" ] && { echo "Gunakan: webforge fw deny <port>"; exit 1; }
      nft add rule inet filter input tcp dport "$target" drop 2>/dev/null || \
      nft add rule ip filter input tcp dport "$target" drop 2>/dev/null
      echo "[+] Port $target berhasil ditutup (deny)."
      ;;
    ban)
      [ -z "$target" ] && { echo "Gunakan: webforge fw ban <ip>"; exit 1; }
      nft add rule inet filter input ip saddr "$target" drop 2>/dev/null || \
      nft add rule ip filter input ip saddr "$target" drop 2>/dev/null
      echo "[+] Alamat IP $target berhasil diblokir (ban)."
      ;;
    unban)
      [ -z "$target" ] && { echo "Gunakan: webforge fw unban <ip>"; exit 1; }
      echo "[i] Untuk mencabut blokir IP $target, jalankan 'nft list ruleset -a' untuk melihat handle rule, lalu hapus dengan 'nft delete rule inet filter input handle <nomor>'."
      ;;
    banlist)
      echo "=== DAFTAR IP/RULE YANG DIBLOKIR ==="
      nft list ruleset 2>/dev/null | grep -E "drop|reject" || echo "Tidak ada IP yang diblokir."
      ;;
    reload)
      echo "[+] Memuat ulang aturan firewall..."
      systemctl restart nftables 2>/dev/null || nft -f /etc/nftables.conf 2>/dev/null
      echo "[+] Aturan firewall berhasil dimuat ulang."
      ;;
    save)
      echo "[+] Menyimpan aturan nftables secara permanen ke /etc/nftables.conf..."
      mkdir -p /etc
      nft list ruleset > /etc/nftables.conf
      echo "[+] Aturan berhasil disimpan."
      ;;
    ports)
      echo "=== DAFTAR PORT TERBUKA (LISTENING PORTS) ==="
      ss -tulpn
      ;;
    *)
      echo "Perintah Firewall tidak dikenal. Ketik 'webforge help'."
      ;;
  esac
}