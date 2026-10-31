#!/usr/bin/env bash

handle_site() {
  local action="$2"
  local domain="$3"
  local arg4="$4"
  
  local SITES_AVAIL="/etc/nginx/sites-available"
  local SITES_ENAB="/etc/nginx/sites-enabled"
  local WEBROOT_BASE="/var/www"

  case "$action" in
    add)
      [ -z "$domain" ] && { echo "Gunakan: webforge site add <domain>"; exit 1; }
      mkdir -p "$WEBROOT_BASE/$domain"
      echo "<h1>Selamat datang di $domain (WebForge OS)</h1>" > "$WEBROOT_BASE/$domain/index.html"
      chown -R www-data:www-data "$WEBROOT_BASE/$domain"
      
      cat << EOF > "$SITES_AVAIL/$domain"
server {
    listen 80;
    server_name $domain;
    root $WEBROOT_BASE/$domain;
    index index.html index.htm;
    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF
      if nginx -t; then
        ln -sf "$SITES_AVAIL/$domain" "$SITES_ENAB/$domain"
        systemctl reload nginx
        echo "[+] Situs $domain berhasil dibuat, diaktifkan, dan direload."
      else
        echo "[-] Tes Nginx gagal, membatalkan pembuatan situs."
        rm -f "$SITES_AVAIL/$domain"
        exit 1
      fi
      ;;
    remove)
      [ -z "$domain" ] && { echo "Gunakan: webforge site remove <domain>"; exit 1; }
      rm -f "$SITES_ENAB/$domain"
      rm -f "$SITES_AVAIL/$domain"
      systemctl reload nginx
      echo "[+] Config & symlink $domain dihapus (webroot dipertahankan)."
      ;;
    purge)
      [ -z "$domain" ] && { echo "Gunakan: webforge site purge <domain>"; exit 1; }
      read -p "Yakin ingin menghapus total config DAN webroot $domain? (y/N): " confirm
      if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm -f "$SITES_ENAB/$domain" "$SITES_AVAIL/$domain"
        rm -rf "$WEBROOT_BASE/$domain"
        systemctl reload nginx
        echo "[+] Situs $domain berhasil dipurge total."
      else
        echo "[!] Dibatalkan."
      fi
      ;;
    enable)
      [ -z "$domain" ] && { echo "Gunakan: webforge site enable <domain>"; exit 1; }
      if [ -f "$SITES_AVAIL/$domain" ]; then
        ln -sf "$SITES_AVAIL/$domain" "$SITES_ENAB/$domain"
        systemctl reload nginx
        echo "[+] Situs $domain diaktifkan."
      else
        echo "[-] Config $domain tidak ditemukan di sites-available."
      fi
      ;;
    disable)
      [ -z "$domain" ] && { echo "Gunakan: webforge site disable <domain>"; exit 1; }
      rm -f "$SITES_ENAB/$domain"
      systemctl reload nginx
      echo "[+] Situs $domain dinonaktifkan."
      ;;
    list)
      echo "=== DAFTAR SITUS WEBFORGE ==="
      for conf in "$SITES_AVAIL"/*; do
        [ -f "$conf" ] || continue
        d=$(basename "$conf")
        if [ -L "$SITES_ENAB/$d" ]; then
          echo " [AKTIF]   $d"
        else
          echo " [NONAKTIF] $d"
        fi
      done
      ;;
    info)
      [ -z "$domain" ] && { echo "Gunakan: webforge site info <domain>"; exit 1; }
      echo "=== INFO SITUS: $domain ==="
      echo "Config: $SITES_AVAIL/$domain"
      echo "Webroot: $WEBROOT_BASE/$domain"
      [ -d "$WEBROOT_BASE/$domain" ] && echo "Ukuran Webroot: $(du -sh "$WEBROOT_BASE/$domain" 2>/dev/null | awk '{print $1}')" || echo "Webroot tidak ditemukan"
      echo "Status: $( [ -L "$SITES_ENAB/$domain" ] && echo "Aktif (Enabled)" || echo "Nonaktif (Disabled)" )"
      ;;
    edit)
      [ -z "$domain" ] && { echo "Gunakan: webforge site edit <domain>"; exit 1; }
      nano "$SITES_AVAIL/$domain"
      if nginx -t; then
        systemctl reload nginx
        echo "[+] Konfigurasi valid, Nginx berhasil direload."
      else
        echo "[-] Konfigurasi Nginx error! Harap periksa kembali."
      fi
      ;;
    rename)
      local lama="$domain"
      local baru="$arg4"
      [ -z "$baru" ] && { echo "Gunakan: webforge site rename <lama> <baru>"; exit 1; }
      mv "$SITES_AVAIL/$lama" "$SITES_AVAIL/$baru"
      mv "$WEBROOT_BASE/$lama" "$WEBROOT_BASE/$baru" 2>/dev/null || true
      sed -i "s/$lama/$baru/g" "$SITES_AVAIL/$baru"
      rm -f "$SITES_ENAB/$lama"
      ln -sf "$SITES_AVAIL/$baru" "$SITES_ENAB/$baru"
      if nginx -t; then
        systemctl reload nginx
        echo "[+] Situs berhasil direname dari $lama ke $baru."
      else
        echo "[-] Error setelah rename, cek konfigurasi."
      fi
      ;;
    clone)
      local asal="$domain"
      local tujuan="$arg4"
      [ -z "$tujuan" ] && { echo "Gunakan: webforge site clone <asal> <tujuan>"; exit 1; }
      cp "$SITES_AVAIL/$asal" "$SITES_AVAIL/$tujuan"
      cp -r "$WEBROOT_BASE/$asal" "$WEBROOT_BASE/$tujuan" 2>/dev/null || mkdir -p "$WEBROOT_BASE/$tujuan"
      sed -i "s/$asal/$tujuan/g" "$SITES_AVAIL/$tujuan"
      ln -sf "$SITES_AVAIL/$tujuan" "$SITES_ENAB/$tujuan"
      if nginx -t; then
        systemctl reload nginx
        echo "[+] Situs $asal berhasil dikloning ke $tujuan."
      else
        echo "[-] Error pada konfigurasi hasil clone."
      fi
      ;;
    redirect)
      local url="$arg4"
      [ -z "$url" ] && { echo "Gunakan: webforge site redirect <domain> <url>"; exit 1; }
      cat << EOF > "$SITES_AVAIL/$domain"
server {
    listen 80;
    server_name $domain;
    return 301 $url\$request_uri;
}
EOF
      if nginx -t; then
        systemctl reload nginx
        echo "[+] Redirect 301 ke $url berhasil dipasang untuk $domain."
      else
        echo "[-] Konfigurasi redirect gagal."
      fi
      ;;
    proxy)
      local backend="$arg4"
      [ -z "$backend" ] && { echo "Gunakan: webforge site proxy <domain> <host:port>"; exit 1; }
      cat << EOF > "$SITES_AVAIL/$domain"
server {
    listen 80;
    server_name $domain;
    location / {
        proxy_pass http://$backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF
      if nginx -t; then
        systemctl reload nginx
        echo "[+] Reverse proxy ke $backend berhasil dipasang untuk $domain."
      else
        echo "[-] Konfigurasi reverse proxy gagal."
      fi
      ;;
    maintenance)
      local mode="$arg4"
      if [ "$mode" == "on" ]; then
        mkdir -p "$WEBROOT_BASE/$domain"
        echo "<h1 style='text-align:center; margin-top:20vh;'>503 - Situs Dalam Pemeliharaan</h1>" > "$WEBROOT_BASE/$domain/maintenance.html"
        cat << EOF > "$SITES_AVAIL/$domain"
server {
    listen 80;
    server_name $domain;
    root $WEBROOT_BASE/$domain;
    index maintenance.html;
    location / {
        return 503;
    }
    error_page 503 /maintenance.html;
    location = /maintenance.html {
        internal;
    }
}
EOF
        if nginx -t; then
          systemctl reload nginx
          echo "[+] Mode maintenance (503) diaktifkan untuk $domain."
        else
          echo "[-] Gagal mengaktifkan maintenance."
        fi
      elif [ "$mode" == "off" ]; then
        # Kembalikan ke config default webroot
        cat << EOF > "$SITES_AVAIL/$domain"
server {
    listen 80;
    server_name $domain;
    root $WEBROOT_BASE/$domain;
    index index.html index.htm;
    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF
        if nginx -t; then
          systemctl reload nginx
          echo "[+] Mode maintenance dimatikan untuk $domain."
        else
          echo "[-] Gagal menonaktifkan maintenance."
        fi
      else
        echo "Gunakan: webforge site maintenance <domain> on|off"
      fi
      ;;
    auth)
      local user="$arg4"
      [ -z "$user" ] && { echo "Gunakan: webforge site auth <domain> <user>"; exit 1; }
      htpasswd -c /etc/nginx/.htpasswd "$user"
      # Tambahkan baris auth_basic ke dalam blok server/location vhost
      sed -i '/location \/ {/a \        auth_basic "Restricted Area";\n        auth_basic_user_file /etc/nginx/.htpasswd;' "$SITES_AVAIL/$domain"
      if nginx -t; then
        systemctl reload nginx
        echo "[+] HTTP Basic Auth berhasil dipasang untuk user $user pada $domain."
      else
        echo "[-] Konfigurasi Basic Auth gagal."
      fi
      ;;
    allow)
      local ip="$arg4"
      [ -z "$ip" ] && { echo "Gunakan: webforge site allow <domain> <ip>"; exit 1; }
      sed -i "/location \/ {/a \        allow $ip;\n        deny all;" "$SITES_AVAIL/$domain"
      if nginx -t; then
        systemctl reload nginx
        echo "[+] Pembatasan akses untuk IP $ip berhasil diterapkan pada $domain."
      else
        echo "[-] Konfigurasi allow IP gagal."
      fi
      ;;
    *)
      echo "Sub-perintah site tidak dikenal. Ketik 'webforge help'."
      ;;
  esac
}