@echo off
	set SOURCE=article
	set OUT=M6-Delta_Debugging

	pdflatex .\%SOURCE%.tex --jobname=%OUT%
	bibtex .\%OUT%
	pdflatex .\%SOURCE%.tex --jobname=%OUT%

	del -f .\*.vrb
	del -f .\*.log
	del -f .\*.nav
	del -f .\*.out
	del -f .\*.snm
	del -f .\*.toc
	del -f .\*.blg
	del -f .\*.zip
	del -f .\*~

	start .\%OUT%.pdf