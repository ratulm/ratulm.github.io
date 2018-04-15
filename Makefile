all: pubs.html pubs-bytopic.html

pubs.html: pubs.bib pubs.pl
	./pubs.pl pubs.bib > $@

pubs-bytopic.html: pubs.bib pubs.pl
	./pubs.pl --mode topic pubs.bib > $@