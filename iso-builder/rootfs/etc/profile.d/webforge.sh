case ":$PATH:" in *:/usr/sbin:*) ;; *) export PATH="$PATH:/usr/sbin" ;; esac
fastfetch() {
  if [ -r "$HOME/.config/fastfetch/config.jsonc" ]; then command fastfetch "$@"
  else command fastfetch -c /etc/xdg/fastfetch/config.jsonc "$@"; fi
}
