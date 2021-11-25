DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))
docs += $(DIR)/design-doc.adoc
pdfs += $(docs:.adoc=.pdf)
htmls += $(docs:.adoc=.html)
docx += $(docs:.adoc=.docx)
puml_src += $(wildcard $(DIR)/puml/*.puml)
puml_svg := $(puml_src:.puml=.svg)
puml_png := $(puml_src:.puml=.png)
options :=  -a pdf-style="$(DIR)/theme/chronicles-theme.yml" -a project-path="$(PROJECT_PATH)" -a platform-path="$(DIR)" -B $(shell pwd)
c4 := $(shell pwd)/build/c4-template
plantuml-icon-font-sprites := $(shell pwd)/build/plantuml-icon-font-sprites

all: puml html pdf docx 
puml: prepare $(puml_svg) $(puml_png)
html: puml $(htmls)
pdf: puml $(pdfs)
docx: puml $(docx)

.PHONY: all pdf html docx clean puml prepare distclean
.NOTPARALLEL:

build_dir:
	@mkdir -p build/docx
	@mkdir -p build/svg
	@mkdir -p build/png

prepare: build_dir $(c4) $(plantuml-icon-font-sprites)
	
$(c4):
	if [ ! -d $(shell pwd)/build/c4-template ]; then \
        wget -T 5 -c https://github.com/plantuml-stdlib/C4-PlantUML/archive/refs/tags/v2.4.0.tar.gz -O $(shell pwd)/build/c4-template.tar.gz && \
		tar -xf $(shell pwd)/build/c4-template.tar.gz -C $(shell pwd)/build/ && \
		mv $(shell pwd)/build/C4-PlantUML-2.4.0 $(shell pwd)/build/c4-template; \
    fi

$(plantuml-icon-font-sprites):
	if [ ! -d $(shell pwd)/build/plantuml-icon-font-sprites ]; then \
        wget -T 5 -c https://github.com/tupadr3/plantuml-icon-font-sprites/archive/refs/tags/v2.4.0.tar.gz -O $(shell pwd)/build/plantuml-icon-font-sprites.tar.gz && \
		tar -xf $(shell pwd)/build/plantuml-icon-font-sprites.tar.gz -C $(shell pwd)/build/ && \
		mv $(shell pwd)/build/plantuml-icon-font-sprites-2.4.0 $(shell pwd)/build/plantuml-icon-font-sprites; \
    fi

# Call asciidoctor to generate $(@F) from $^
%.pdf: %.adoc
	bundler exec asciidoctor-pdf $^ $(options) -o build/pdf/$(@F)

%.html: %.adoc
	bundler exec asciidoctor --backend html5 -a data-uri $(options) $^ -o build/html/$(@F)

%.docx: %.adoc
	bundler exec asciidoctor --backend docbook $(options) -o - $^ \
	| pandoc --from=docbook --to=docx --output build/docx/$(@F) --highlight-style espresso

%.svg: %.puml
	java -jar $(DIR)/tool/plantuml.jar -DRELATIVE_INCLUDE="$(shell pwd)/build/c4-template" $^ -tsvg -o "$(shell pwd)/build/svg/"

%.png: %.puml
	java -jar $(DIR)/tool/plantuml.jar -DRELATIVE_INCLUDE="$(shell pwd)/build/c4-template"  $^ -tpng -o "$(shell pwd)/build/png/"

clean:
	@rm -rf build/pdf build/html build/svg build/png build/docx

distclean:
	@rm -rf build