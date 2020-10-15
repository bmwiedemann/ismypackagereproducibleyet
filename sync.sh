#!/bin/sh
rsync -a web/cgi/impryo.cgi root@vm12.zq1.de.:/usr/lib/cgi-bin/
rsync -a web/css/main.css root@vm12.zq1.de.:/var/www/zq1/impryo/
rsync -a cache/out/ root@vm12.zq1.de.:/usr/local/share/impryo/
