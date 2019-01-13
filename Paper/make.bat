@echo off
	set SOURCE=article

	pdflatex .\%SOURCE%.tex
	bibtex .\%SOURCE%
	pdflatex .\%SOURCE%.tex

	del -f .\*.vrb
	del -f .\*.log
	del -f .\*.nav
	del -f .\*.out
	del -f .\*.snm
	del -f .\*.toc
	del -f .\*.blg
	del -f .\*.zip
	del -f .\*~

	start .\%SOURCE%.pdf