prefix = /usr/local
exec_prefix = $(prefix)
bindir = $(exec_prefix)/bin
datarootdir = $(prefix)/share
mandir = $(datarootdir)/man
man1dir = $(mandir)/man1

CC = cc
CFLAGS = -g -O2 -W -Wall -Wwrite-strings
INSTALL = install

WFDB_CFLAGS = `wfdb-config --cflags`
WFDB_LIBS = `wfdb-config --libs`

all: wfdbcheck

wfdbcheck: wfdbcheck.o
	$(CC) $(CFLAGS) $(LDFLAGS) wfdbcheck.o -o wfdbcheck $(WFDB_LIBS)

wfdbcheck.o: wfdbcheck.c messages.h
	$(CC) $(CFLAGS) $(CPPFLAGS) $(WFDB_CFLAGS) -c wfdbcheck.c

messages.h: wfdbcheck.c gen-messages
	-sed -f gen-messages < wfdbcheck.c > messages.h.tmp
	-sed -f gen-messages-mac < wfdbcheck.c > messages.h.tmp
	if $(CC) $(CFLAGS) $(CPPFLAGS) $(WFDB_CFLAGS) -DNO_MESSAGES \
	   '-Dprint_msg(a,b,c,d,e,f,...)=WFDBCHECKMSG(f)' \
	   -E wfdbcheck.c > msg0.tmp; then \
	  grep -o 'WFDBCHECKMSG(".*")' < msg0.tmp | \
	    sed -e 's/" "//g' -e 's/.*("/"/' -e 's/")/",/' | \
	    sort | uniq > msg1.tmp; \
	  grep '^"' messages.h.tmp | sort > msg2.tmp; \
	  diff msg1.tmp msg2.tmp; \
	fi
	mv messages.h.tmp messages.h
	rm -f msg*.tmp

install: wfdbcheck
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(INSTALL) -m 755 wfdbcheck $(DESTDIR)$(bindir)/wfdbcheck
	$(INSTALL) -m 755 wfdbcheckdb $(DESTDIR)$(bindir)/wfdbcheckdb
	$(INSTALL) -d $(DESTDIR)$(man1dir)
	$(INSTALL) -m 644 wfdbcheck.1 $(DESTDIR)$(man1dir)/wfdbcheck.1
	$(INSTALL) -m 644 wfdbcheckdb.1 $(DESTDIR)$(man1dir)/wfdbcheckdb.1

uninstall:
	rm -f $(DESTDIR)$(bindir)/wfdbcheck
	rm -f $(DESTDIR)$(bindir)/wfdbcheckdb
	rm -f $(DESTDIR)$(man1dir)/wfdbcheck.1
	rm -f $(DESTDIR)$(man1dir)/wfdbcheckdb.1

clean:
	rm -f wfdbcheck
	rm -f *.o
	rm -f msg*.tmp

distclean: clean
	rm -f messages.h

.PHONY: all clean distclean install uninstall
