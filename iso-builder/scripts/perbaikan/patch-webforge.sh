#!/bin/bash
mountpoint -q /mnt/lfs || { echo "STOP: sda2 belum ter-mount"; exit 1; }
D=/mnt/lfs/usr/lib/webforge/modules
mkdir -p ~/iso-builder/webforge-modules.bak && cp -a $D/. ~/iso-builder/webforge-modules.bak/
python3 - <<'PYEOF'
import sys
D = '/mnt/lfs/usr/lib/webforge/modules/'
def patch(f, old, new):
    s = open(D + f).read()
    if s.count(old) != 1:
        sys.exit('STOP: pola tidak cocok persis 1x di %s (ditemukan %d): %s' % (f, s.count(old), old))
    open(D + f, 'w').write(s.replace(old, new, 1))
    print('OK', f)
new_auth = r'''{ read -rsp "Password untuk $user: " _pw; echo; printf '%s:%s\n' "$user" "$(printf '%s' "$_pw" | openssl passwd -apr1 -stdin)" > /etc/nginx/.htpasswd; unset _pw; }'''
patch('site.sh', 'htpasswd -c /etc/nginx/.htpasswd "$user"', new_auth)
patch('system.sh', 'host google.com ', 'getent hosts google.com ')
PYEOF
bash -n $D/site.sh && bash -n $D/system.sh && echo SYNTAX-OK
echo "-- uji alat pengganti:"
chroot /mnt/lfs /usr/bin/env -i PATH=/usr/sbin:/usr/bin /usr/bin/bash -c 'printf "%s" uji | openssl passwd -apr1 -stdin; getent hosts localhost'
echo "-- baris hasil patch:"
grep -n 'openssl passwd\|getent hosts' $D/site.sh $D/system.sh | cut -c1-170
