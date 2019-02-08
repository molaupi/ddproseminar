DOKUMENT = article

make:
	pdflatex $(DOKUMENT).tex -output-format=pdf -shell-escape

bib:
	bibtex $(DOKUMENT).aux

clean:
	rm -f *.vrb *.log *.nav *.out *.snm *.toc *.blg *.zip *~

full:
	make
	make bib
	make
	make clean
