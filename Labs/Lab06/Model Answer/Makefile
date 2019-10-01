
%.pdf: %.Rnw
	R CMD Sweave $<
	pdflatex $*.tex

%.html: %.Rmd
	Rscript -e 'library(rmarkdown); render("$<")'
