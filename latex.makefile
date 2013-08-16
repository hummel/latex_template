### Latex.Make
# Author: Jason Hiebel

# This is a simple makefile for compiling LaTeX documents.

# Targets:
#    default : compiles the document in to three formats (DVI -> PS -> PDF)
#    display : displays the compiled document in a common PDF viewer.
#              (Linux = Evince, OSX = OS Set Default)
#    clean   : removes the obj/ directory holding temporary files


# Set PROJECT to the name of the .tex file to build.
PROJECT = 

default: obj/$(PROJECT).pdf

display: default
	(${PDFVIEWER} obj/$(PROJECT).pdf &)

lpr: default
	lpr obj/$(PROJECT).pdf &

### Compilation Flags
LATEX_FLAGS  = -halt-on-error -quiet -output-directory obj/

TEXMFOUTPUT = obj/


### File Types (for dependancies)
TEX_FILES = $(shell find . -name '*.tex')
BIB_FILES = $(shell find . -name '*.bib')
STY_FILES = $(shell find . -name '*.sty')
CLS_FILES = $(shell find . -name '*.cls')
BST_FILES = $(shell find . -name '*.bst')
EPS_FILES = $(shell find . -name '*.eps')


### Standard PDF Viewers

UNAME := $(shell uname)

ifeq ($(UNAME), Linux)
PDFVIEWER = okular
endif
ifeq ($(UNAME), Darwin)
PDFVIEWER = open
endif


### Clean
# This target cleans the temporary files generated by the tex programs in
# use. All temporary files generated by this makefile will be placed in obj/
# so cleanup is easy.

clean::
	rm -rf obj/


### Core Latex Generation
# Performs the typical build process for latex generations so that all
# references are resolved correctly. If adding components to this run-time
# always take caution and implement the worst case set of commands.
# Example: latex, bibtex, latex, latex
#
# Note the use of order-only prerequisites (prerequisites following the |).
# Order-only prerequisites do not affect the target -- if the order-only
# prerequisite has changed and none of the normal prerequisites have changed
# then this target IS NOT run.

obj/:
	mkdir -p obj/

obj/$(PROJECT).aux: $(TEX_FILES) $(STY_FILES) $(CLS_FILES) $(EPS_FILES) | obj/
	pdflatex $(LATEX_FLAGS) $(PROJECT)

obj/$(PROJECT).bbl: $(BIB_FILES) $(BST_FILES) | obj/$(PROJECT).aux
ifneq ($(BIB_FILES),)
	cp *.bib obj
	( cd obj && bibtex $(PROJECT) )
	pdflatex $(LATEX_FLAGS) $(PROJECT)
endif
	
obj/$(PROJECT).pdf: obj/$(PROJECT).aux obj/$(PROJECT).bbl
	pdflatex $(LATEX_FLAGS) $(PROJECT)
