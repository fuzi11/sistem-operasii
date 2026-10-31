#!/usr/bin/env bash

handle_ssl() {
  local action="$2"
  local domain="$3"
  local SITES_AVAIL="/etc/nginx/sites-available"
  
  # Cari lokasi acme.sh secara dinamis
  local ACME=""
  if [ -f "/root/.acme.sh/acme.sh" ]; then
    ACME="/root/.acme.sh/acme.sh"
  elif command -v acme.sh &> /dev/null; then
    ACME="acme.sh"
  else
    echo "[-] Peringatan: acme.sh tidak ditemukan di sistem. Fitur Let's Encrypt memerlukan acme.sh."
    if [ "$action" == "list" ] || [ "$action" == "renew" ]; then
      exit 1
    fi
  fi

  case "$action" in
    issue)
      [ -z "$domain" ] && { echo "Gunakan: webforge ssl issue <domain>"; exit 1; }
      [ -z "$ACME" ] && { echo "[-] acme.sh tidak tersedia."; exit 1; }
      echo "[+] Meminta sertifikat Let's Encrypt untuk $domain..."
      
      "$ACME" --issue -d "$domain" -w "/var/www/$domain" --nginx
      
      mkdir -p /etc/ssl/certs /etc/ssl/private
      "$ACME" --install-cert -d "$domain" \
        --key-file /etc/ssl/private/"$domain".key \
        --fullchain-file /etc/ssl/certs/"$domain".crt \
        --reloadcmd "systemctl reload nginx"
      
      if [ -f "$SITES_AVAIL/$domain" ]; then
        cat << EOF > "$SITES_AVAIL/$domain"
server {
    listen 80;
    server_name $domain;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $domain;
    root /var/www/$domain;
    index index.html index.htm;

    ssl_certificate /etc/ssl/certs/$domain.crt;
    ssl_certificate_key /etc/ssl/private/$domain.key;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF
        if nginx -t; then
          systemctl reload nginx
          echo "[+] SSL berhasil diterbitkan dan vhost Nginx dikonfigurasi untuk $domain."
        else
          echo "[-] Error pada konfigurasi SSL Nginx."
        fi
      fi
      ;;
    renew)
      [ -z "$ACME" ] && { echo "[-] acme.sh tidak tersedia."; exit 1; }
      echo "[+] Memperbarui semua sertifikat SSL..."
      "$ACME" --renew-all --force
      systemctl reload nginx
      echo "[+] Pembaruan sertifikat selesai."
      ;;
    list)
      [ -z "$ACME" ] && { echo "[-] acme.sh tidak tersedia. Belum ada sertifikat terdaftar."; exit 0; }
      echo "=== DAFTAR SERTIFIKAT SSL (acme.sh) ==="
      "$ACME" --list
      ;;
    check)
      [ -z "$domain" ] && { echo "Gunakan: webforge ssl check <domain>"; exit 1; }
      echo "=== MEMERIKSA RANTAI SSL UNTUK: $domain ==="
      openssl s_client -connect "$domain:443" -servername "$domain" < /dev/null 2>/dev/null | openssl x509 -noout -dates -subject -issuer
      ;;
    revoke)
      [ -z "$domain" ] && { echo "Gunakan: webforge ssl revoke <domain>"; exit 1; }
      [ -z "$ACME" ] && { echo "[-] acme.sh tidak tersedia."; exit 1; }
      echo "[+] Mencabut sertifikat untuk $domain..."
      "$ACME" --revoke -d "$domain"
      "$ACME" --remove -d "$domain"
      echo "[+] Sertifikat berhasil dicabut."
      ;;
    selfsigned)
      [ -z "$domain" ] && { echo "Gunakan: webforge ssl selfsigned <domain>"; exit 1; }
      echo "[+] Membuat sertifikat self-signed untuk $domain..."
      mkdir -p /etc/ssl/private /etc/ssl/certs
      openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/private/"$domain".key \
        -out /etc/ssl/certs/"$domain".crt \
        -subj "/CN=$domain"
      
      cat << EOF > "$SITES_AVAIL/$domain"
server {
    listen 80;
    server_name $domain;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $domain;
    root /var/www/$domain;
    index index.html index.htm;

    ssl_certificate /etc/ssl/certs/$domain.crt;
    ssl_certificate_key /etc/ssl/private/$domain.key;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF
      if nginx -t; then
        systemctl reload nginx
        echo "[+] Sertifikat self-signed berhasil dibuat dan dipasang untuk $domain."
      else
        echo "[-] Gagal mengonfigurasi vhost self-signed."
      fi
      ;;
    force)
      [ -z "$domain" ] && { echo "Gunakan: webforge ssl force <domain>"; exit 1; }
      echo "[+] Memaksa redirect HTTP ke HTTPS untuk $domain..."
      if [ -f "$SITES_AVAIL/$domain" ]; then
        if ! grep -q "return 301 https" "$SITES_AVAIL/$domain"; then
          sed -i 's/listen 80;/listen 80;\n    return 301 https:\/\/\$host\$request_uri;/' "$SITES_AVAIL/$domain"
        fi
        if nginx -t; then
          systemctl reload nginx
          echo "[+] Redirect HTTP ke HTTPS berhasil dipaksa untuk $domain."
        else
          echo "[-] Gagal menerapkan force HTTPS."
        fi
      else
        echo "[-] Konfigurasi situs $domain tidak ditemukan."
      fi
      ;;
    *)
      echo "Perintah SSL tidak dikenal. Ketik 'webforge help'."
      ;;
  esac
}