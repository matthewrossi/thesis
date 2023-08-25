.PHONY: all pdf thumbnail zip read clean

FILE = main

# colors
RED = '\033[0;31m'
ORG = '\033[0;33m'
NOC = '\033[0m'

# commands
SHELL := /bin/bash

# pdflatex env
 PDFCMD = pdflatex -interaction=nonstopmode -shell-escape ${FILE}
# latex env
# PDFCMD = bash -c "latex -interaction=nonstopmode ${FILE} && \
#                   dvips -t letter ${FILE}.dvi && \
#                   ps2pdf ${FILE}.ps"

ifeq ($(shell grep -q '^[^%]*\\bibliography{' ${FILE}.tex; echo $$?),1)
	BIBCMD = true
else
	BIBCMD = bibtex ${FILE}
endif

UNAME := $(shell uname)

all: $(FILE).tex | clean pdf

$(FILE).pdf pdf: $(FILE).tex
	@$(PDFCMD) &>/dev/null || true
	@$(BIBCMD) &>/dev/null || (echo -e ${ORG} && $(BIBCMD) || printf ${NOC} || true)
	@$(PDFCMD) &>/dev/null || (echo -e ${RED} && $(PDFCMD) || printf ${NOC} && false)
	@$(PDFCMD) &>/dev/null

$(FILE).jpg thumbnail: $(FILE).pdf
	@convert -thumbnail 600x -background white -alpha remove $<[0] $(FILE).jpg

$(FILE).zip zip: | clean
	@zip -x $(FILE).zip -r $(FILE).zip .

read: $(FILE).pdf
ifeq ($(UNAME),Darwin)
	@open ${FILE}.pdf &>/dev/null &
else ifeq ($(UNAME),Linux)
	@xdg-open ${FILE}.pdf &>/dev/null &
endif

clean:
	@rm -f ${FILE}.{pdf,dvi,ps,jpg,log,aux,out,bbl,blg,synctex.gz,toc,vrb,snm,nav,zip,tdo,lof,lot,run.xml,fls,fdb_latexmk}
	@find . -name "*-converted-to.pdf" -exec rm '{}' +
	@find . -name "*.pyg" -exec rm '{}' +
	@rm -f missfont.log
	@rm -rf cache
	@rm -rf _minted*
	@rm -rf auto
