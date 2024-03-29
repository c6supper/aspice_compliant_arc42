DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))
# docs += $(DIR)/design-doc.adoc
pdfs += $(docs:.adoc=.pdf) 
htmls += $(docs:.adoc=.html)
odt += $(docs:.adoc=.odt)

presentation += $(presentation_docs:.adoc=.html)

# puml_src += $(wildcard $(DIR)/puml/*.puml)
puml_svg := $(puml_src:.puml=.svg) $(puml_src:.wsd=.svg)
puml_png := $(puml_src:.puml=.png) $(puml_src:.wsd=.png)
adoc_options := -r asciidoctor-diagram -a scripts=cjk -a project-path="$(PROJECT_PATH)" -a utility-path="$(DIR)" $(custom_adoc_option)
c4 := $(shell pwd)/build/c4-template
plantuml-icon-font-sprites := $(shell pwd)/build/plantuml-icon-font-sprites
theme_options := -DTHEME_INCLUDE=$(DIR)/theme
puml_options := -DRELATIVE_INCLUDE="$(shell pwd)/build/c4-template" -DENV_INCLUDE="$(shell pwd)/src"
cjk := $(shell pwd)/build/font
archimate := $(shell pwd)/build/archimate-template
puml_options += -DARCHIMATE_RELATIVE_INCLUDE="$(shell pwd)/build/archimate-template"

presentation_dep := $(shell pwd)/build/$(LANGUAGE)/presentation/resource/

ifeq ($(strip $(QC_ARCH)),8155)
	puml_options += -DQC_ARCH="$(QC_ARCH)"
	adoc_options += -a qc_arch="$(QC_ARCH)"
else
	puml_options += -DQC_ARCH="8295"
	adoc_options += -a qc_arch="8295"
endif

ifeq ($(strip $(LANGUAGE)),)
	LANGUAGE = en
endif

ifeq ($(strip $(LOG_LEVEL)),)
	LOG_LEVEL = info
endif

puml_options += -DLOG_LEVEL="$(LOG_LEVEL)"

plantuml_include_options = -Dplantuml.include.path="$(shell pwd)/src/resource/iuml:$(shell pwd)/src/resource/json/:$(shell pwd)/src/resource/json/$(LANGUAGE):$(shell pwd)/src/srs_doc/platform/resource/json"

adoc_options += -a language="$(LANGUAGE)" -a data-uri

all: puml html pdf odt presentation
puml_png: prepare $(puml_png)
puml: prepare $(puml_svg)
html: puml $(htmls)
pdf: puml $(pdfs)
odt: puml $(odt)
presentation: html $(presentation) $(presentation_dep)

.PHONY: all pdf html odt clean puml prepare distclean
# .NOTPARALLEL:

build_dir:
	@mkdir -p build/$(LANGUAGE)/odt
	@mkdir -p build/$(LANGUAGE)/svg
	@mkdir -p build/$(LANGUAGE)/png

prepare: build_dir $(c4) $(archimate) $(plantuml-icon-font-sprites) $(cjk) $(presentation_dep)
	
$(c4):
	if [ ! -d $(shell pwd)/build/c4-template ]; then \
        wget -T 5 -c https://github.com/plantuml-stdlib/C4-PlantUML/archive/refs/heads/master.zip -O $(shell pwd)/build/c4-template.zip && \
		unzip -q $(shell pwd)/build/c4-template.zip -d $(shell pwd)/build/ && \
		mv $(shell pwd)/build/C4-PlantUML-master $(shell pwd)/build/c4-template; \
    fi

$(archimate):
	if [ ! -d $(shell pwd)/build/archimate-template ]; then \
        wget -T 5 -c https://github.com/plantuml-stdlib/Archimate-PlantUML/archive/refs/heads/master.zip -O $(shell pwd)/build/archimate-template.zip && \
		unzip -q $(shell pwd)/build/archimate-template.zip -d $(shell pwd)/build/ && \
		mv $(shell pwd)/build/Archimate-PlantUML-master $(shell pwd)/build/archimate-template; \
    fi

$(plantuml-icon-font-sprites):
	if [ ! -d $(shell pwd)/build/plantuml-icon-font-sprites ]; then \
        wget -T 5 -c https://github.com/tupadr3/plantuml-icon-font-sprites/archive/refs/tags/v2.4.0.tar.gz -O $(shell pwd)/build/plantuml-icon-font-sprites.tar.gz && \
		tar -xf $(shell pwd)/build/plantuml-icon-font-sprites.tar.gz -C $(shell pwd)/build/ && \
		mv $(shell pwd)/build/plantuml-icon-font-sprites-2.4.0 $(shell pwd)/build/plantuml-icon-font-sprites; \
    fi

$(cjk):
	if [ ! -d $(shell pwd)/build/font ]; then \
		tar -xf $(DIR)/resource/font.tar.xz -C $(shell pwd)/build/; \
    fi

$(presentation_dep):
	if [ ! -d $(shell pwd)/build/$(LANGUAGE)/presentation/resource ] && [ -d $(shell pwd)/src/presentation_doc/resource ]; then \
		mkdir -p $(shell pwd)/build/$(LANGUAGE)/presentation/resource && cp -rf $(shell pwd)/src/presentation_doc/resource/* $(shell pwd)/build/$(LANGUAGE)/presentation/resource/; \
    fi

# Call asciidoctor to generate $(@F) from $^
%.pdf: %.adoc
	bundler exec asciidoctor-pdf $^ $(adoc_options) -o build/$(LANGUAGE)/pdf/$@

%.html: %.adoc
	bundler exec asciidoctor --backend html5 -a data-uri $(adoc_options) $^ -o build/$(LANGUAGE)/html/$@

%.odt: %.adoc
	mkdir -p $(shell pwd)/build/$(LANGUAGE)/odt/$(@D) && bundler exec asciidoctor --backend docbook $(adoc_options) -o - $^ \
	| pandoc --toc --from=docbook --reference-doc $(DIR)/theme/reference.odt --to=odt --output $(shell pwd)/build/$(LANGUAGE)/odt/$@ --highlight-style espresso

%.svg: %.puml
	java $(plantuml_include_options) -jar $(DIR)/tool/plantuml.jar $(puml_options) $(theme_options) $^ -charset UTF-8 -tsvg -o "$(shell pwd)/build/$(LANGUAGE)/svg/$(@D)"

%.png: %.puml
	java $(plantuml_include_options) -jar $(DIR)/tool/plantuml.jar $(puml_options) $(theme_options)  $^ -charset UTF-8 -tpng -o "$(shell pwd)/build/$(LANGUAGE)/png/$(@D)"

$(presentation) : $(presentation_docs) 
	bundle exec asciidoctor-revealjs $^ -b revealjs $(adoc_options) -a revealjsdir=https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.9.2 -D build/$(LANGUAGE)/presentation/

clean:
	@rm -rf build/$(LANGUAGE)/pdf build/$(LANGUAGE)/html build/$(LANGUAGE)/svg build/$(LANGUAGE)/png build/$(LANGUAGE)/odt build/$(LANGUAGE)/presentation

distclean:
	@rm -rf build