docs := index.adoc
pdfs := $(docs:.adoc=.pdf)
htmls := $(docs:.adoc=.html)
options :=  -a pdf-style="./theme/chronicles-theme.yml"
all: html pdf
pdf: $(pdfs)
html: $(htmls)
.PHONY: all pdf html clean

# Call asciidoctor to generate $@ from $^
%.pdf: %.adoc
	bundler exec asciidoctor-pdf $^ $(options) -o build/pdf/$@

%.html: %.adoc
	bundler exec asciidoctor $^ -o build/html/$@
	@cp -rf images build/html/

clean:
	@rm -rf build