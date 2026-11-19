#!/bin/bash
set -e
L=/mnt/lfs
HTML=${1:-$L/var/www/html/index.html}
M=$L/usr/lib/webforge
H=$M/modules/help.sh
CH="chroot $L /usr/bin/env -i HOME=/root TERM=dumb PATH=/usr/sbin:/usr/bin /usr/bin/bash"
mountpoint -q $L || { echo "STOP: sda2 belum ter-mount"; exit 1; }
[ -f "$HTML" ] || { echo "STOP: $HTML tidak ada"; exit 1; }
[ -f $H ] || { echo "STOP: help.sh tidak ada"; exit 1; }

echo "== 1. baca daftar perintah dari halaman web =="
python3 - "$HTML" "$M/help.tsv" <<'PYEOF'
import re, sys
src, dst = sys.argv[1], sys.argv[2]
s = open(src, encoding='utf-8').read()
m = re.search(r"var cats = (\[.*?\]);\s*\n\s*var tabs", s, re.S)
if not m:
    sys.exit('STOP: data "var cats" tidak ditemukan di halaman')
toks = re.findall(r"\[|\]|'(?:[^'\\]|\\.)*'", m.group(1))
stack = [[]]
for t in toks:
    if t == '[':
        stack.append([])
    elif t == ']':
        x = stack.pop(); stack[-1].append(x)
    else:
        stack[-1].append(re.sub(r"\\(.)", r"\1", t[1:-1]))
cats = stack[0][0]
rows, total = [], 0
for cid, title, desc, cmds in cats:
    rows.append('\t'.join(['C', cid, title, desc]))
    for cmd, d in cmds:
        rows.append('\t'.join(['K', cid, 'webforge ' + cmd, d])); total += 1
open(dst, 'w', encoding='utf-8').write('\n'.join(rows) + '\n')
print('[ok] %d kelompok, %d perintah -> %s' % (len(cats), total, dst))
PYEOF
chmod 644 $M/help.tsv

echo "== 2. cek help.sh yang ada =="
FN=$(grep -oE '^[[:space:]]*(function[[:space:]]+)?[A-Za-z_][A-Za-z0-9_]*[[:space:]]*\(\)' $H | sed -E 's/function//; s/[()[:space:]]//g' || true)
NF=$(printf '%s' "$FN" | grep -c . || true)
echo "fungsi di help.sh: ${FN:-<tidak ada>}"
if [ "$NF" != 1 ]; then
  echo "STOP: help.sh tidak berisi tepat 1 fungsi. help.sh TIDAK diubah. Isi saat ini:"
  echo "-----"; cat $H; echo "-----"
  grep -nE 'help|modules/' $L/usr/bin/webforge | cut -c1-160 | head -20
  exit 2
fi

echo "== 3. tulis help.sh baru =="
cp -a $H /root/iso-builder/help.sh.bak
cat > $H <<'HEOF'
# help.sh - bantuan webforge, dibuat dari daftar perintah di halaman web.
# Data: /usr/lib/webforge/help.tsv  (C = kelompok, K = perintah)

__FN__() {
  local data=/usr/lib/webforge/help.tsv q cid matches total ncat c0="" c1="" c2=""
  [ -r "$data" ] || { echo "[-] Berkas bantuan tidak ditemukan: $data"; return 1; }
  [ "${1:-}" = "help" ] && shift
  q=$(printf '%s' "$*" | tr 'A-Z' 'a-z' | sed -E 's/^[[:space:]]*(webforge[[:space:]]+)?//; s/[[:space:]]+$//')
  if [ -t 1 ]; then c0=$'\e[0m'; c1=$'\e[1;36m'; c2=$'\e[2m'; fi
  total=$(awk -F'\t' '$1=="K"{n++} END{print n+0}' "$data")
  ncat=$(awk -F'\t' '$1=="C"{n++} END{print n+0}' "$data")

  if [ -z "$q" ]; then
    printf '%sWebForge OS 1.0 LTS%s  %s perintah dalam %s kelompok\n' "$c1" "$c0" "$total" "$ncat"
    echo "Pemakaian: webforge <perintah> [argumen]"
    awk -F'\t' -v c1="$c1" -v c0="$c0" -v c2="$c2" '
      $1=="C" { i++; printf "\n%s%d. %s%s %s- %s%s\n", c1, i, $3, c0, c2, $4, c0; next }
      $1=="K" { printf "  %-46s %s\n", $3, $4 }' "$data"
    echo
    echo "Bantuan kelompok : webforge help <kelompok>  (site, nginx, ssl, fw, log, sec, backup, net, auto, help)"
    echo "Bantuan perintah : webforge help <perintah>  (contoh: webforge help site add)"
    return 0
  fi

  cid=$(awk -F'\t' -v q="$q" '$1=="C" && tolower($2)==q {print $2; exit}' "$data")
  [ -n "$cid" ] || cid=$(awk -F'\t' -v q="$q" 'length(q)>=4 && $1=="C" && index(tolower($3), q)>0 {print $2; exit}' "$data")
  if [ -n "$cid" ]; then
    awk -F'\t' -v id="$cid" -v c1="$c1" -v c0="$c0" '
      $1=="C" && $2==id { printf "%s%s%s\n%s\n\n", c1, $3, c0, $4 }
      $1=="K" && $2==id { printf "  %-46s %s\n", $3, $4 }' "$data"
    return 0
  fi

  matches=$(awk -F'\t' -v q="$q" '$1=="K" { c=tolower($3); sub(/^webforge /, "", c); if (index(c, q)==1) printf "  %-46s %s\n", $3, $4 }' "$data")
  [ -n "$matches" ] || matches=$(awk -F'\t' -v q="$q" '$1=="K" { c=tolower($3); sub(/^webforge /, "", c); if (index(c, q)>0) printf "  %-46s %s\n", $3, $4 }' "$data")
  if [ -n "$matches" ]; then printf '%s\n' "$matches"; return 0; fi
  echo "[-] Tidak ada bantuan untuk '$q'. Jalankan: webforge help"
  return 1
}
HEOF
sed -i "s/__FN__/$FN/g" $H
bash -n $H && echo "[ok] sintaks help.sh (fungsi: $FN)"

echo "== 4. uji lewat webforge =="
EXPECT=$(awk -F'\t' '$1=="K"{n++} END{print n+0}' $M/help.tsv)
$CH -c 'webforge help 2>&1' | cat > /tmp/wf-help.txt || true
GOT=$(grep -c '^  webforge ' /tmp/wf-help.txt || true)
if [ "$GOT" = "$EXPECT" ]; then echo "[ok] webforge help menampilkan $GOT perintah (halaman web: $EXPECT)"
else echo "[GAGAL] webforge help menampilkan $GOT perintah, seharusnya $EXPECT"; head -20 /tmp/wf-help.txt
  echo "-- pemanggil di /usr/bin/webforge:"; grep -n "$FN\|help" $L/usr/bin/webforge | cut -c1-160 | head -10; fi
echo; head -14 /tmp/wf-help.txt
echo; echo "-- webforge help ssl:";        $CH -c 'webforge help ssl 2>&1' | cat | head -12
echo; echo "-- webforge help site add:";   $CH -c 'webforge help site add 2>&1' | cat
echo; echo "-- webforge help tidakada:";   $CH -c 'webforge help tidakada 2>&1' | cat
echo "== selesai sync-help =="
