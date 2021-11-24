DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))
docs += $(DIR)/design-doc.adoc
pdfs += $(docs:.adoc=.pdf)
htmls += $(docs:.adoc=.html)
docx += $(docs:.adoc=.docx)
puml_src += $(wildcard $(DIR)/puml/*.puml)
puml_svg := $(puml_src:.puml=.svg)
puml_png := $(puml_src:.puml=.png)
options :=  -a pdf-style="$(DIR)/theme/chronicles-theme.yml" -a project-path="$(PROJECT_PATH)" -a platform-path="$(DIR)" -B $(shell pwd)

all: puml html pdf docx 
puml: $(puml_svg) $(puml_png)
html: puml $(htmls)
pdf: puml $(pdfs)
docx: puml $(docx)
.PHONY: all pdf html docx clean puml
.NOTPARALLEL:

# Call asciidoctor to generate $(@F) from $^
%.pdf: %.adoc
	bundler exec asciidoctor-pdf $^ $(options) -o build/pdf/$(@F)

%.html: %.adoc
	bundler exec asciidoctor --backend html5 -a data-uri $(options) $^ -o build/html/$(@F)

%.docx: %.adoc
	mkdir -p build/docx
	bundler exec asciidoctor --backend docbook $(options) -o - $^ \
	| pandoc --from=docbook --to=docx --output build/docx/$(@F) --highlight-style espresso

%.svg: %.puml
	@mkdir -p build/svg
	java -jar $(DIR)/tool/plantuml.jar $^ -tsvg -o "$(shell pwd)/build/svg/"

%.png: %.puml
	@mkdir -p build/png
	java -jar $(DIR)/tool/plantuml.jar $^ -tpng -o "$(shell pwd)/build/png/"

clean:
	@rm -rf build