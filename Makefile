# Makefile :-- install esk.
# Copyright (C) 2010 Tom Kazimiers (tom AT voodoo-arts.net)
# Based on the Makefile of emp latex package by Thorsten Ohl
# (Thorsten.Ohl@Physik.TH-Darmstadt.de)
#
# Esk is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# Esk is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# $Id: Makefile,v 1.0 2010/02/25 21:14:41 kazimiers Exp $
#
########################################################################

VERSION = 0
RELEASE = 2 
STATUS  = WIP

########################################################################

# Directories
prefix = $(HOME)
texdir = $(prefix)/tex/inputs
docdir = $(texdir)/doc

# Commands
INSTALL = install -c -m 755
INSTALL_DATA = install -c -m 644
# INSTALL = cp
# INSTALL_DATA = cp

LATEX = latex
SK = sketch
MAKEINDEX = makeindex
DVIPS = dvips
DFLAGS =
FILES="*.sk"

########################################################################
# No user serviceable parts below:
########################################################################

RESOLVE_XREF = \
  $(LATEX) $*.drv && \
  while grep 'Rerun to get cross-references right\.' $*.log; \
  do \
    $(LATEX) $*.drv; \
  done

RUN_MAKEINDEX = \
  $(MAKEINDEX) -s gind.ist -o $*.ind $*.idx && \
  $(MAKEINDEX) -s gglo.ist -o $*.gls $*.glo

all: esk.sty esk.drv

man: eskman.dvi

ps: esk.ps

dvi: esk.dvi

install: all
	$(INSTALL_DATA) esk.sty $(texdir)

install.doc: all
	$(INSTALL_DATA) esk.dtx $(docdir)
	$(INSTALL_DATA) esk.drv $(docdir)
	$(INSTALL_DATA) eskman.drv $(docdir)

uninstall:
	rm -f $(texdir)/esk.sty

uninstall.doc:
	rm -f $(docdir)/esk.dtx
	rm -f $(docdir)/esk.drv
	rm -f $(docdir)/eskman.drv

esk.sty: esk.dtx esk.ins
	$(LATEX) esk.ins

esk.drv eskman.drv: esk.sty

esk.dvi: esk.dtx esk.drv esk.sty
	-$(LATEX) $*.drv
	for i in `ls *.sk`; do $(SK) -o "$$i.tex" "$$i"; done
	-$(LATEX) $*.drv
	$(RUN_MAKEINDEX)
	$(RESOLVE_XREF)

eskman.dvi: esk.dtx eskman.drv esk.sty
	-$(LATEX) $*.drv
	for i in `ls *.sk`; do $(SK) -o "$$i.tex" "$$i"; done
	-$(LATEX) $*.drv
	$(RUN_MAKEINDEX)
	$(RESOLVE_XREF)

manual.ps.gz: manual.ps
	gzip < $< > $@

manual.ps: eskman.dvi $(MANPICS)
	$(DVIPS) $(DFLAGS) -o $@ $<

esk.ps: esk.dvi $(MANPICS)
	$(DVIPS) $(DFLAGS) -o $@ $<

clean:
	rm -f *.mp *.rawmp *.[0-9]* \
	      *.log *.dvi *.aux *.toc *.ilg *.glo *.gls *.idx *.ind \
	      *.ps *.mpx '#*#' *~ .*~

realclean: clean
	rm -f esk.sty esk.drv eskman*

distclean: realclean

########################################################################
# Maintenance:

DISTFILES = /usr/local/etc/COPYING README Makefile esk.dtx esk.ins

distdir = esk-$(VERSION).$(RELEASE)$(STATUS)
CVSTAG = ESK_$(VERSION)_$(RELEASE)$(STATUS)
TEXTAG = v$(VERSION).$(RELEASE)
M =

fileversion:
	perl -pe \
	  's/^\\def\\fileversion\{.*\}/\\def\\fileversion{$(TEXTAG)}/;' \
	  esk.dtx > esk.vtmp
	if cmp -s esk.dtx esk.vtmp; then \
	  rm -f esk.vtmp; \
	else \
	  mv esk.vtmp esk.dtx; \
	fi

commit: fileversion
	@if test -n "$(M)"; then \
	  echo "cvs commit -m '$(M)'"; cvs commit -m '$(M)'; \
	  echo "cvs tag $(CVSTAG)"; cvs tag $(CVSTAG); \
	  echo "cvs tag -b $(CVSTAG)_"; cvs tag -b $(CVSTAG)_; \
	else \
	  echo "usage: make commit M='<message>'" 1>&2; \
	fi

dist: $(distdir).tar.gz
snap: esk-current.tar.gz

$(distdir).tar.gz:
	rm -fr $(distdir) $(distdir).tmp
	cvs export -r $(CVSTAG) -d $(distdir).tmp esk
	mkdir $(distdir)
	(cd ./$(distdir).tmp && \
         make $(DISTFILES) && \
         cp $(DISTFILES) ../$(distdir))
	tar cf - $(distdir) | gzip > $@
	rm -fr $(distdir) $(distdir).tmp

esk-current.tar.gz: $(DISTFILES) fileversion
	rm -fr esk-current
	mkdir esk-current
	touch esk-current/1_THIS_IS_A_SNAPSHOT_OF_
	touch esk-current/2_WORK_IN_PROGRESS_AND__
	touch esk-current/3_NOT_YET_RELEASED_CODE_
	cp $(DISTFILES) esk-current
#	perl -pe \
#	  's/\[\\filedate/[(UNRELEASED and UNSUPPORTED snapshot)/;' \
	  esk.dtx > esk-current/esk.dtx
	tar cf - esk-current | gzip > $@
	rm -fr esk-current

########################################################################
# Local Variables:
# mode:text
# End:
