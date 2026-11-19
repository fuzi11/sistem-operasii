#!/usr/bin/env bash
# Modul firewall WebForge OS (nftables).
# Tabel inet filter. Set: allowed_tcp (port TCP terbuka), blocklist4 dan blocklist6 (IP diblokir).

_fw_active() { nft list table inet filter >/dev/null 2>&1; }

_fw_need_active() {
  _fw_active && return 0
  echo "[-] Firewall belum aktif. Jalankan: webforge fw enable"
  return 1
}

_fw_valid_port() {
  case "$1" in
    ""|*[!0-9-]*|-*|*-|*-*-*) return 1 ;;
  esac
  local a="${1%%-*}" b="${1##*-}"
  [ "$a" -ge 1 ] && [ "$b" -le 65535 ] && [ "$a" -le "$b" ]
}

_fw_ip_family() {
  case "$1" in
    ""|*[!0-9a-fA-F:./]*) return 1 ;;
    *:*) printf '6' ;;
    *.*) printf '4' ;;
    *) return 1 ;;
  esac
}

_fw_open_ports() {
  nft list set inet filter allowed_tcp 2>/dev/null | tr '\n\t' '  ' \
    | grep -oE 'elements = \{[^}]*\}' | sed -E 's/elements = \{ *//; s/ *\}//'
}

_fw_sync_ssh() {
  local p
  for p in $(sshd -T 2>/dev/null | awk '$1=="port"{print $2}'); do
    if nft add element inet filter allowed_tcp "{ $p }" 2>/dev/null; then
      echo "[i] Port SSH $p ditambahkan ke daftar terbuka. Jalankan 'webforge fw save' agar permanen."
    fi
  done
}

handle_fw() {
  local action="$2"
  local target="$3"
  local err fam yn list

  case "$action" in
    status)
      echo "=== STATUS FIREWALL ==="
      printf 'Layanan   : %s\n' "$(systemctl is-active nftables 2>/dev/null || true)"
      printf 'Autostart : %s\n' "$(systemctl is-enabled nftables 2>/dev/null || true)"
      if _fw_active; then
        echo
        echo "=== ATURAN NFTABLES ==="
        nft list ruleset
      else
        echo
        echo "[-] Firewall tidak aktif (tidak ada aturan yang dimuat). Jalankan: webforge fw enable"
      fi
      ;;
    enable)
      [ -s /etc/nftables.conf ] || { echo "[-] /etc/nftables.conf tidak ada atau kosong."; exit 1; }
      if ! err=$(nft -c -f /etc/nftables.conf 2>&1); then
        echo "[-] Aturan firewall tidak valid, firewall TIDAK diaktifkan:"
        echo "$err"
        exit 1
      fi
      echo "[+] Mengaktifkan firewall (nftables)..."
      systemctl enable nftables >/dev/null 2>&1
      if systemctl is-active --quiet nftables; then
        systemctl reload nftables 2>/dev/null
      else
        systemctl start nftables 2>/dev/null
      fi
      if _fw_active; then
        _fw_sync_ssh
        echo "[+] Firewall aktif dan akan berjalan otomatis saat boot."
        echo "    Port TCP terbuka: $(_fw_open_ports)"
      else
        echo "[-] Gagal menjalankan layanan nftables. Detail:"
        systemctl status nftables --no-pager 2>&1 | tail -n 8
        exit 1
      fi
      ;;
    disable)
      echo "[!] PERINGATAN: firewall akan dimatikan dan SEMUA port menjadi terbuka."
      if [ "$target" != "-y" ] && [ "$target" != "--yes" ]; then
        read -r -p "Lanjutkan? [y/N] " yn
        case "$yn" in y|Y|ya|Ya|YA) ;; *) echo "Dibatalkan."; exit 0 ;; esac
      fi
      systemctl disable nftables >/dev/null 2>&1
      systemctl stop nftables >/dev/null 2>&1
      nft flush ruleset 2>/dev/null
      echo "[+] Firewall dimatikan dan tidak berjalan saat boot. Aktifkan lagi: webforge fw enable"
      ;;
    allow)
      [ -z "$target" ] && { echo "Gunakan: webforge fw allow <port>   (contoh: 8080 atau 8000-8100)"; exit 1; }
      _fw_valid_port "$target" || { echo "[-] Port tidak valid: $target"; exit 1; }
      _fw_need_active || exit 1
      if err=$(nft add element inet filter allowed_tcp "{ $target }" 2>&1); then
        echo "[+] Port $target berhasil dibuka (allow). Jalankan 'webforge fw save' agar permanen."
      elif echo "$err" | grep -qi 'exist'; then
        echo "[i] Port $target sudah terbuka."
      else
        echo "[-] Gagal membuka port $target: $err"; exit 1
      fi
      ;;
    deny)
      [ -z "$target" ] && { echo "Gunakan: webforge fw deny <port>"; exit 1; }
      _fw_valid_port "$target" || { echo "[-] Port tidak valid: $target"; exit 1; }
      _fw_need_active || exit 1
      [ "$target" = "22" ] && echo "[!] PERINGATAN: menutup port 22 dapat memutus akses SSH baru."
      if err=$(nft delete element inet filter allowed_tcp "{ $target }" 2>&1); then
        echo "[+] Port $target berhasil ditutup (deny). Jalankan 'webforge fw save' agar permanen."
      else
        echo "[i] Port $target tidak sedang dibuka (atau tidak cocok dengan rentang yang ada)."
      fi
      ;;
    ban)
      [ -z "$target" ] && { echo "Gunakan: webforge fw ban <ip>"; exit 1; }
      fam=$(_fw_ip_family "$target") || { echo "[-] Bukan alamat IP yang valid: $target"; exit 1; }
      _fw_need_active || exit 1
      if err=$(nft add element inet filter "blocklist$fam" "{ $target }" 2>&1); then
        echo "[+] Alamat IP $target berhasil diblokir (ban). Jalankan 'webforge fw save' agar permanen."
      elif echo "$err" | grep -qi 'exist'; then
        echo "[i] $target sudah ada di daftar blokir."
      else
        echo "[-] Gagal memblokir $target: $err"; exit 1
      fi
      ;;
    unban)
      [ -z "$target" ] && { echo "Gunakan: webforge fw unban <ip>"; exit 1; }
      fam=$(_fw_ip_family "$target") || { echo "[-] Bukan alamat IP yang valid: $target"; exit 1; }
      _fw_need_active || exit 1
      if err=$(nft delete element inet filter "blocklist$fam" "{ $target }" 2>&1); then
        echo "[+] Blokir $target dicabut (unban). Jalankan 'webforge fw save' agar permanen."
      else
        echo "[i] $target tidak ada di daftar blokir."
      fi
      ;;
    banlist)
      _fw_need_active || exit 1
      echo "=== DAFTAR IP YANG DIBLOKIR ==="
      list=$({ nft list set inet filter blocklist4; nft list set inet filter blocklist6; } 2>/dev/null \
        | tr '\n\t' '  ' | grep -oE 'elements = \{[^}]*\}' \
        | sed -E 's/elements = \{ *//; s/ *\}//; s/, */\n/g')
      if [ -n "$list" ]; then echo "$list"; else echo "Tidak ada IP yang diblokir."; fi
      ;;
    reload)
      [ -s /etc/nftables.conf ] || { echo "[-] /etc/nftables.conf tidak ada atau kosong."; exit 1; }
      if ! err=$(nft -c -f /etc/nftables.conf 2>&1); then
        echo "[-] Aturan firewall tidak valid, aturan yang berjalan TIDAK diubah:"
        echo "$err"
        exit 1
      fi
      echo "[+] Memuat ulang aturan firewall..."
      if systemctl is-active --quiet nftables; then
        systemctl reload nftables 2>/dev/null || nft -f /etc/nftables.conf
      else
        systemctl start nftables 2>/dev/null || nft -f /etc/nftables.conf
      fi
      echo "[+] Aturan firewall berhasil dimuat ulang."
      ;;
    save)
      _fw_need_active || exit 1
      echo "[+] Menyimpan aturan nftables secara permanen ke /etc/nftables.conf..."
      local tmp=/etc/nftables.conf.tmp
      { echo '#!/usr/sbin/nft -f'; echo '# Disimpan oleh: webforge fw save'; echo 'flush ruleset'; echo; nft list ruleset; } > "$tmp"
      if nft -c -f "$tmp" 2>/dev/null; then
        cp -a /etc/nftables.conf /etc/nftables.conf.bak 2>/dev/null
        cat "$tmp" > /etc/nftables.conf
        rm -f "$tmp"
        echo "[+] Aturan berhasil disimpan (cadangan: /etc/nftables.conf.bak)."
      else
        rm -f "$tmp"
        echo "[-] Aturan yang berjalan gagal divalidasi, berkas TIDAK diubah."
        exit 1
      fi
      ;;
    ports)
      echo "=== DAFTAR PORT TERBUKA (LISTENING PORTS) ==="
      ss -tulpn
      ;;
    *)
      echo "Perintah firewall tidak dikenal. Ketik 'webforge help fw'."
      ;;
  esac
}
