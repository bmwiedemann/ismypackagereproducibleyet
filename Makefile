all: fetch db

fetch:
	mkdir -p cache/in cache/out
	(cd cache/in && wget -x -N https://rb.zq1.de/compare.factory/reproducible.json https://tests.reproducible-builds.org/{archlinux,debian}/reproducible.json )

db: cache/out/opensuse.db cache/out/archlinux.db cache/out/debian.db
cache/out/opensuse.db: cache/in/rb.zq1.de/compare.factory/reproducible.json
	./json2db.pl $@ < $<

cache/out/archlinux.db: cache/in/tests.reproducible-builds.org/archlinux/reproducible.json
	./json2db.pl $@ < $<

cache/out/debian.db: cache/in/tests.reproducible-builds.org/debian/reproducible.json
	./json2db.pl $@ < $<

clean:
	rm -r cache
