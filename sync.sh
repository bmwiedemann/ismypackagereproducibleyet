#!/bin/sh
d=root@vm12.zq1.de.:
rsync -a web/cgi/impryo.cgi $d/usr/lib/cgi-bin/
rsync -a web/css/main.css $d/var/www/zq1/impryo/
rsync -a cache/out/ $d/usr/local/share/impryo/
