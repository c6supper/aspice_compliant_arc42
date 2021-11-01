DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))
docs := $(DIR)/design-doc.adoc
pdfs := $(docs:.adoc=.pdf)
htmls := $(docs:.adoc=.html)
docx := $(docs:.adoc=.docx)
options :=  -a pdf-style="$(DIR)/theme/chronicles-theme.yml" -a project-path="$(PROJECT_PATH)" -a platform-path="$(DIR)" -B $(shell pwd)
all: html pdf docx
pdf: $(pdfs)
html: $(htmls)
docx: $(docx)
.PHONY: all pdf html docx clean

# Call asciidoctor to generate $(@F) from $^
%.pdf: %.adoc
	bundler exec asciidoctor-pdf $^ $(options) -o build/pdf/$(@F)

%.html: %.adoc
	bundler exec asciidoctor --backend html5 -a data-uri $(options) $^ -o build/html/$(@F)

%.docx: %.adoc
	mkdir -p build/docx
	bundler exec asciidoctor --backend docbook $(options) -o - $^ \
	| pandoc --from=docbook --to=docx --output build/docx/$(@F) --highlight-style espresso

clean:
	rm -rf build