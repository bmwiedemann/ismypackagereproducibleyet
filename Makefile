SHELL=bash
wget=wget --progress=dot:mega -N
all: fetch db

fetch:
	mkdir -p cache/in cache/out
	(cd cache/in && ${wget} -x https://rb.zq1.de/compare.factory/reproducible.json https://tests.reproducible-builds.org/debian/reproducible.json https://reproducible.archlinux.org/api/v0/pkgs/list https://qa.guix.gnu.org/reproducible.json )

sync: db
	perl -c web/cgi/impryo.cgi
	./sync.sh

db: cache/out/opensuse.db cache/out/archlinux.db cache/out/debian.db cache/out/guix.db
cache/out/opensuse.db: cache/in/rb.zq1.de/compare.factory/reproducible.json
	./json2db.pl $@ < $<

cache/out/archlinux.db: cache/in/reproducible.archlinux.org/api/v0/pkgs/list
	./json2db.pl $@ < $<

cache/out/debian.db: cache/in/tests.reproducible-builds.org/debian/reproducible.json
	./json2db.pl $@ < $<

cache/out/guix.db: cache/in/qa.guix.gnu.org/reproducible.json
	./json2db.pl $@ < $<

clean:
	rm -r cache
