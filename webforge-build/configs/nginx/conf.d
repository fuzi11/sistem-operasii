mkdir -p /etc/nginx/conf.d

cat << 'EOF' > /etc/nginx/conf.d/default.conf
server {
    listen       80;
    server_name  localhost;

    location / {
        root   /var/www/html;
        index  index.html index.htm;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /var/www/html;
    }
}
EOF