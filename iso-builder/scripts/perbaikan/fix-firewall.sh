#!/bin/bash
set -e
L=/mnt/lfs
IB=/root/iso-builder
CH="chroot $L /usr/bin/env -i HOME=/root TERM=dumb PATH=/usr/sbin:/usr/bin /usr/bin/bash"
mountpoint -q $L || { echo "STOP: sda2 belum ter-mount"; exit 1; }
[ -f $L/usr/lib/webforge/modules/fw.sh ] || { echo "STOP: fw.sh tidak ada"; exit 1; }
for k in NF_TABLES NF_TABLES_INET NFT_CT NF_CONNTRACK; do
  grep -qE "^CONFIG_$k=y" $L/boot/config-7.1.8-live || { echo "STOP: kernel belum punya CONFIG_$k (jalankan build-kernel-nft.sh dulu)"; exit 1; }
done
echo "[ok] kernel mendukung nftables"
mkdir -p $IB/firewall-lama
cp -a $L/etc/nftables.conf $L/etc/systemd/system/nftables.service $L/usr/lib/webforge/modules/fw.sh $IB/firewall-lama/
echo "[backup] berkas firewall lama -> $IB/firewall-lama/"

echo "== 1. aturan dasar =="
cat > $L/root/nftables.baru <<'EOF'
#!/usr/sbin/nft -f
# WebForge OS firewall. Kelola dengan: webforge fw ...
flush ruleset

table inet filter {
    set allowed_tcp {
        type inet_service
        flags interval
        elements = { 22, 80, 443 }
    }
    set blocklist4 {
        type ipv4_addr
        flags interval
    }
    set blocklist6 {
        type ipv6_addr
        flags interval
    }

    chain input {
        type filter hook input priority 0; policy drop;

        iifname "lo" accept
        ct state invalid drop
        ct state established,related accept
        ip saddr @blocklist4 drop
        ip6 saddr @blocklist6 drop
        ip protocol icmp accept
        ip6 nexthdr ipv6-icmp accept
        ip6 daddr fe80::/64 udp dport 546 accept
        tcp dport @allowed_tcp accept
    }
    chain forward {
        type filter hook forward priority 0; policy drop;
    }
    chain output {
        type filter hook output priority 0; policy accept;
    }
}
EOF
if err=$($CH -c 'nft -c -f /root/nftables.baru' 2>&1); then echo "[ok] sintaks aturan valid (nft -c)"
else echo "[GAGAL] aturan tidak valid:"; echo "$err"; rm -f $L/root/nftables.baru; exit 1; fi
install -m 600 $L/root/nftables.baru $L/etc/nftables.conf
rm -f $L/root/nftables.baru

echo "== 2. unit systemd =="
cat > $L/etc/systemd/system/nftables.service <<'EOF'
[Unit]
Description=WebForge OS firewall (nftables)
DefaultDependencies=no
After=local-fs.target
Before=network-pre.target
Wants=network-pre.target
ConditionFileNotEmpty=/etc/nftables.conf

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStartPre=/usr/sbin/nft -c -f /etc/nftables.conf
ExecStart=/usr/sbin/nft -f /etc/nftables.conf
ExecReload=/usr/sbin/nft -c -f /etc/nftables.conf
ExecReload=/usr/sbin/nft -f /etc/nftables.conf
ExecStop=/usr/sbin/nft flush ruleset

[Install]
WantedBy=multi-user.target
EOF
mkdir -p $L/etc/systemd/system/multi-user.target.wants
ln -sf /etc/systemd/system/nftables.service $L/etc/systemd/system/multi-user.target.wants/nftables.service
ls -l $L/etc/systemd/system/multi-user.target.wants/nftables.service | sed "s|$L||"
$CH -c 'systemd-analyze verify /etc/systemd/system/nftables.service 2>&1 | head -5' || true

echo "== 3. fw.sh baru =="
cat > $L/usr/lib/webforge/modules/fw.sh <<'FWEOF'
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
FWEOF
bash -n $L/usr/lib/webforge/modules/fw.sh && echo "[ok] sintaks fw.sh"

echo "== 4. uji fungsi validasi =="
$CH > /tmp/wf-fwtest.txt <<'EOF'
source /usr/lib/webforge/modules/fw.sh
chk() { local want=$1; shift; "$@" >/dev/null 2>&1; local rc=$?
  if [ "$want" = ok ] && [ $rc = 0 ]; then echo "[ok]    $*"
  elif [ "$want" = no ] && [ $rc != 0 ]; then echo "[ok]    ditolak: $*"
  else echo "[GAGAL] harusnya $want: $*"; fi; }
chk ok _fw_valid_port 80
chk ok _fw_valid_port 8000-8100
chk ok _fw_valid_port 65535
chk no _fw_valid_port 0
chk no _fw_valid_port 70000
chk no _fw_valid_port abc
chk no _fw_valid_port 1-2-3
chk no _fw_valid_port 90-80
chk no _fw_valid_port ""
chk ok _fw_ip_family 203.0.113.5
chk ok _fw_ip_family 10.0.0.0/24
chk ok _fw_ip_family 2001:db8::1
chk no _fw_ip_family "1.2.3.4 }; flush ruleset; {"
chk no _fw_ip_family abc
chk no _fw_ip_family ""
EOF
cat /tmp/wf-fwtest.txt
grep -q GAGAL /tmp/wf-fwtest.txt && { echo "STOP: ada uji validasi yang gagal"; exit 1; }

echo "== 5. halaman web dan help.tsv =="
python3 - <<'PYEOF'
import re, sys
p = '/mnt/lfs/var/www/html/index.html'
s = open(p, encoding='utf-8').read()
if "['fw enable'" in s:
    print('[skip] halaman web sudah memuat fw enable')
else:
    old = "['fw status','Tampilkan aturan aktif'],"
    if s.count(old) != 1:
        sys.exit('STOP: baris fw status tidak ditemukan persis 1x, halaman web tidak diubah')
    new = old + "['fw enable','Aktifkan firewall sekarang dan saat boot'],['fw disable','Matikan firewall (semua port terbuka)'],"
    open('/root/iso-builder/index.html.sebelum-fw', 'w', encoding='utf-8').write(s)
    open(p, 'w', encoding='utf-8').write(s.replace(old, new))
    print('[ok] halaman web: fw enable dan fw disable ditambahkan')
s = open(p, encoding='utf-8').read()
m = re.search(r"var cats = (\[.*?\]);\s*\n\s*var tabs", s, re.S)
if not m:
    sys.exit('STOP: data "var cats" tidak ditemukan')
toks = re.findall(r"\[|\]|'(?:[^'\\]|\\.)*'", m.group(1))
stack = [[]]
for t in toks:
    if t == '[': stack.append([])
    elif t == ']':
        x = stack.pop(); stack[-1].append(x)
    else: stack[-1].append(re.sub(r"\\(.)", r"\1", t[1:-1]))
cats = stack[0][0]
rows, total = [], 0
for cid, title, desc, cmds in cats:
    rows.append('\t'.join(['C', cid, title, desc]))
    for cmd, d in cmds:
        rows.append('\t'.join(['K', cid, 'webforge ' + cmd, d])); total += 1
open('/mnt/lfs/usr/lib/webforge/help.tsv', 'w', encoding='utf-8').write('\n'.join(rows) + '\n')
print('[ok] help.tsv: %d kelompok, %d perintah' % (len(cats), total))
PYEOF
$CH -c 'webforge help fw 2>&1' | cat

echo "== 6. perintah lain yang memakai nft =="
grep -n 'nft ' $L/usr/lib/webforge/modules/*.sh | grep -v '/fw.sh' | cut -c1-170 || echo "(tidak ada)"
echo "== selesai fix-firewall =="
