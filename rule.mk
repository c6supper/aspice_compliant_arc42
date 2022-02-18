DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))
# docs += $(DIR)/design-doc.adoc
pdfs += $(docs:.adoc=.pdf) 
htmls += $(docs:.adoc=.html)
odt += $(docs:.adoc=.odt)

# puml_src += $(wildcard $(DIR)/puml/*.puml)
puml_svg := $(puml_src:.puml=.svg)
puml_png := $(puml_src:.puml=.png)
adoc_options := -a scripts=cjk -a project-path="$(PROJECT_PATH)" -a utility-path="$(DIR)"
c4 := $(shell pwd)/build/c4-template
plantuml-icon-font-sprites := $(shell pwd)/build/plantuml-icon-font-sprites
theme_options := -DTHEME_INCLUDE=$(DIR)/theme
c4_options := -DRELATIVE_INCLUDE="$(shell pwd)/build/c4-template"
cjk := $(shell pwd)/build/font

ifeq ($(strip $(EE_ARCH)),3.x)
	c4_options += -DEE_ARCH="3.x"
	adoc_options += -a ee_arch="$(3.x)"
else
	c4_options += -DEE_ARCH="4.0"
	adoc_options += -a ee_arch="$(4.0)"
endif

ifeq ($(strip $(LANGUAGE)),)
	LANGUAGE = en
endif

ifeq ($(strip $(LOG_LEVEL)),)
	LOG_LEVEL = info
endif

c4_options += -DLOG_LEVEL="$(LOG_LEVEL)"

plantuml_include_options = -Dplantuml.include.path="$(shell pwd)/src/resource/iuml:$(shell pwd)/src/resource/json/:$(shell pwd)/src/resource/json/$(LANGUAGE)"

adoc_options += -a language="$(LANGUAGE)"

all: puml html pdf odt 
# puml: prepare $(puml_svg) $(puml_png)
puml: prepare $(puml_svg)
html: puml $(htmls)
pdf: puml $(pdfs)
odt: puml $(odt)

.PHONY: all pdf html odt clean puml prepare distclean
# .NOTPARALLEL:

build_dir:
	@mkdir -p build/odt
	@mkdir -p build/svg
	@mkdir -p build/png

prepare: build_dir $(c4) $(plantuml-icon-font-sprites) $(cjk)
	
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

$(cjk):
	if [ ! -d $(shell pwd)/build/font ]; then \
		tar -xf $(DIR)/resource/font.tar.xz -C $(shell pwd)/build/; \
    fi

# Call asciidoctor to generate $(@F) from $^
%.pdf: %.adoc
	bundler exec asciidoctor-pdf $^ $(adoc_options) -o build/pdf/$@

%.html: %.adoc
	bundler exec asciidoctor --backend html5 -a data-uri $(adoc_options) $^ -o build/html/$@

%.odt: %.adoc
	mkdir -p $(shell pwd)/build/odt/$(@D) && bundler exec asciidoctor --backend docbook $(adoc_options) -o - $^ \
	| pandoc --toc --from=docbook --reference-doc $(DIR)/theme/reference.odt --to=odt --output $(shell pwd)/build/odt/$@ --highlight-style espresso

%.svg: %.puml
	java $(plantuml_include_options) -jar $(DIR)/tool/plantuml.jar $(c4_options) $(theme_options) $^ -charset UTF-8 -tsvg -o "$(shell pwd)/build/svg/$(@D)"

%.png: %.puml
	java $(plantuml_include_options) -jar $(DIR)/tool/plantuml.jar $(c4_options) $(theme_options)  $^ -charset UTF-8 -tpng -o "$(shell pwd)/build/png/$(@D)"

clean:
	@rm -rf build/pdf build/html build/svg build/png build/odt

distclean:
	@rm -rf build