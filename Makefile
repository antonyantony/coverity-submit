# Makefile for the coverity-submit tool

VERS=$(shell sed <coverity-submit -n -e '/version *= *"\(.*\)"/s//\1/p')

CODE    = coverity-submit
DOCS    = README coverity-submit.xml COPYING NEWS
SOURCES = $(CODE) $(DOCS) Makefile control

all: coverity-submit.1

coverity-submit.html: coverity-submit.xml
	xmlto xhtml-nochunks coverity-submit.xml

coverity-submit.1: coverity-submit.xml
	xmlto man coverity-submit.xml

install: coverity-submit.1 uninstall
	cp coverity-submit ${DESTDIR}/usr/bin/coverity-submit 
	install -m 755 -o 0 -g 0 -d ${DESTDIR}/usr/share/man/man1/
	install -m 755 -o 0 -g 0 coverity-submit.1 ${DESTDIR}/usr/share/man/man1/coverity-submit.1

uninstall:
	rm -f ${DESTDIR}/usr/bin/coverity-submit 
	rm -f ${DESTDIR}/usr/share/man/man1/coverity-submit.1

coverity-submit-$(VERS).tar.gz: $(SOURCES) coverity-submit.1
	tar --transform='s:^:coverity-submit-$(VERS)/:' --show-transformed-names -cvzf coverity-submit-$(VERS).tar.gz $(SOURCES)

coverity-submit-$(VERS).md5: coverity-submit-$(VERS).tar.gz
	@md5sum coverity-submit-$(VERS).tar.gz >coverity-submit-$(VERS).md5

pychecker:
	@ln -f coverity-submit coverity-submit.py
	@-pychecker --only --limit 50 coverity-submit.py
	@rm -f coverity-submit.py

PYLINTOPTS = --rcfile=/dev/null --reports=n \
	--msg-template="{path}:{line}: [{msg_id}({symbol}), {obj}] {msg}" \
	--dummy-variables-rgx='^_'
SUPPRESSIONS = --disable="C0103,C0111,C0301"
PY3K_SUPPRESSIONS = --disable="C0325,F0401,E1101"
pylint:
	@pylint $(PYLINTOPTS) $(SUPPRESSIONS) $(PY3K_SUPPRESSIONS) coverity-submit

clean:
	rm -f *.pyc *.html coverity-submit.1 MANIFEST ChangeLog
	rm -f *.tar.gz *.md5

dist: coverity-submit-$(VERS).tar.gz

release: coverity-submit-$(VERS).tar.gz coverity-submit-$(VERS).md5 coverity-submit.html
	shipper version=$(VERS) | sh -e -x

refresh: coverity-submit.html
	shipper -N -w version=$(VERS) | sh -e -x
