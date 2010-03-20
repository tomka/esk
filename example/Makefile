# Directories
prefix = $(HOME)
texdir = $(prefix)/tex/inputs
docdir = $(texdir)/doc

# Commands
INSTALL = install -c -m 755
INSTALL_DATA = install -c -m 644
# INSTALL = cp
# INSTALL_DATA = cp

LATEX = pdflatex
MP = TEX=$(LATEX) mpost
SK = sketch
MAKEINDEX = makeindex
DVIPS = dvips
DFLAGS =

# Set TeX inputs
TEXINPUTS := "../:$(TEXINPUTS)"

all: example

example: esk_ex.tex
	echo Building example
	$(LATEX) esk_ex.tex
	for i in *.sk; do $(SK) -o "$$i.tex" "$$i"; done
	$(LATEX) esk_ex.tex

clean:
	rm -f *.[0-9]* \
	      *.log *.dvi *.aux *.toc *.ilg *.glo *.gls *.idx *.ind \
	      *.ps *.pdf *.sk *.mpx '#*#' *~ .*~
