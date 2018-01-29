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
	
	location /hello/ {
		proxy_pass http://127.0.0.1:8080;
	}
}
EOF

nginx -t && service nginx start && curl -I localhost

> /home/box/web/hello.py
cat<<EOF >> /home/box/web/hello.py
from cgi import parse_qs
def app(environ, start_response):
#    data = b"Hello, World!\n"
    d = parse_qs(environ['QUERY_STRING'])
    for i in d.get:
        resp_body += i
    start_response("200 OK", [
        ("Content-Type", "text/plain"),
        ("Content-Length", str(len(resp_body)))
    ])
    #return iter([data])
    
    return iter([resp_body])
EOF

> /home/box/web/etc/hello.py
ln -s /home/box/web/etc/hello.py /etc/gunicorn.d/hello.py

cat<<EOF >> /home/box/web/etc/hello.py
CONFIG = {
	'mode': 'wsgi',
	'working_dir': '/home/box/web',
	'python': '/usr/bin/python',
	'args': (
		'--bind=0.0.0.0:8080',
		'--workers=4',
		'--timeout=60',
		'hello:app',
	),
}
EOF
/etc/init.d/gunicorn start && curl -I localhost:8080
