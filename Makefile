docs := index.adoc
pdfs := $(docs:.adoc=.pdf)
htmls := $(docs:.adoc=.html)
docx := $(docs:.adoc=.docx)
options :=  -a pdf-style="./theme/chronicles-theme.yml"
all: html pdf docx
pdf: $(pdfs)
html: $(htmls)
docx: $(docx)
.PHONY: all pdf html docx clean

# Call asciidoctor to generate $@ from $^
%.pdf: %.adoc
	bundler exec asciidoctor-pdf $^ $(options) -o build/pdf/$@

%.html: %.adoc
	bundler exec asciidoctor --backend html5 -a data-uri $^ -o build/html/$@

%.docx: %.adoc
	mkdir -p build/docx
	bundler exec asciidoctor --backend docbook -o - $^ \
	| pandoc --from=docbook --to=docx --output build/docx/$@ --highlight-style espresso

clean:
	rm -rf build