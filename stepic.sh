mkdir -p /home/box/web/{public,etc,uploads}
mkdir  /home/box/web/public/{img,css,js}
chown -R box:box /home/box/web/

sed -i 's/user www-data/user box/g' /etc/nginx/nginx.conf
rm /etc/nginx/sites-enabled/default
> /home/box/web/etc/site.conf
ln -s /home/box/web/etc/site.conf /etc/nginx/sites-enabled/site.conf

cat << EOF >> /home/box/web/etc/site.conf
server {
	listen 80;
	server_name _;

	location ^~ /uploads/ {
		root /home/box/web/;
	}

	location ~ \.\w\w\w?\w?$ {
		root /home/box/web/public;
	}

	location / {
		return 404;
	}
}
EOF

nginx -t && service nginx start

> /home/box/web/hello.py
cat<<EOF >> /home/box/web/hello.py
    def app(environ, start_response):
        data = b"Hello, World!\n"
        start_response("200 OK", [
            ("Content-Type", "text/plain"),
            ("Content-Length", str(len(data)))
        ])
        return iter([data])
EOF

> /home/box/web/etc/gunicorn.conf

#cat<<EOF >> /home/box/web/gunicorn.conf
#CONFIG = {
#
#}
#EOF
