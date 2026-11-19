#!/bin/bash
set -e
L=/mnt/lfs
H=$L/usr/lib/webforge/modules/help.sh
BAK=/root/iso-builder/help.sh.bak
CH="chroot $L /usr/bin/env -i HOME=/root TERM=dumb PATH=/usr/sbin:/usr/bin /usr/bin/bash"
mountpoint -q $L || { echo "STOP: sda2 belum ter-mount"; exit 1; }
[ -f $BAK ] || { echo "STOP: backup help.sh lama tidak ada ($BAK)"; exit 1; }
grep -q 'doctor' $BAK || { echo "STOP: backup tidak memuat logika doctor"; exit 1; }
if grep -q '_wf_help_lama' $H; then echo "[skip] sudah dipatch"; exit 0; fi
[ "$(grep -c '^show_help()' $BAK)" = 1 ] || { echo "STOP: show_help() di backup tidak tepat 1x"; exit 1; }

echo "== baris doctor di help.sh lama =="
grep -n 'doctor' $BAK | cut -c1-150 | head -10

cp -a $H /root/iso-builder/help.sh.baru
{ sed 's/^show_help()/_wf_help_lama()/' $BAK; echo; cat /root/iso-builder/help.sh.baru; } > $H.tmp
python3 - <<'PYEOF'
p = '/mnt/lfs/usr/lib/webforge/modules/help.sh.tmp'
s = open(p).read()
old = '  [ "${1:-}" = "help" ] && shift\n'
new = old + '  if [ "${1:-}" = "doctor" ]; then _wf_help_lama doctor; return $?; fi\n'
if s.count(old) != 1:
    raise SystemExit('STOP: pola shift tidak ditemukan persis 1x, help.sh tidak diubah')
open(p, 'w').write(s.replace(old, new))
PYEOF
bash -n $H.tmp || { echo "STOP: sintaks tidak valid, help.sh tidak diubah"; rm -f $H.tmp; exit 1; }
mv $H.tmp $H
echo "[ok] help.sh: logika doctor lama dipertahankan"

echo "== uji =="
$CH -c 'source /usr/lib/webforge/modules/help.sh; declare -F show_help _wf_help_lama'
GOT=$($CH -c 'webforge help 2>&1' | grep -c '^  webforge ' || true)
echo "webforge help menampilkan $GOT perintah (harus 95)"
echo "-- webforge doctor (maks 30 detik):"
$CH -c 'timeout 30 webforge doctor 2>&1' | head -20 || true
echo "== selesai patch-doctor =="
