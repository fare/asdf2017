ae := asdf2017

src = asdf2017.scrbl utils.rkt bibliography.scrbl
# asdf3.scrbl old-bug.scrbl history.scrbl tutorial.scrbl

#export PLTCOLLECTS:=$(shell pwd):${PLTCOLLECTS}

all: asdf2017.PDF
ann: asdf2017-annotated.PDF
html: ${ae}.html
pdf: ${ae}.pdf
PDF: pdf ${ae}.PDF

install: asdf2017.html asdf2017.pdf
	rsync -av --delete $^ *.js *.css ~/files/asdf2017/
	rsync -av --delete ~/files/asdf2017/ bespin:files/asdf2017/

%.W: %.html
	w3m -T text/html $<

%.wc: %.html
	donuts.pl unhtml < $< | wc

%.PDF: %.pdf
	evince -f -i $${p:-1} $<

%.pdf: %.scrbl ${src}
	time scribble --dest-name $@ --pdf $<

${ae}.html: ${ae}.scrbl ${src}
%.html: %.scrbl utils.rkt bibliography.scrbl
	time scribble --dest-name $@ --html $<

%.latex: %.scrbl ${src}
	time scribble --latex --dest tmp $<

clean:
	rm -f *.pdf *.html *.tex *.css *.js
	rm -rf tmp

mrproper:
	git clean -xfd

rsync: html pdf
	rsync -av ${ae}.html ${ae}.pdf common-lisp.net:~frideau/public_html/asdf2017/

els:
	slideshow --start $${p:-1} els2017-slides.ss

els2017-slides.pdf: els2017-slides.ss
	slideshow --pdf -o $@ $<
