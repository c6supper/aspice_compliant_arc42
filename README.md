## Why
1. **Driven by ASPICE, configurable traceable, constant etc.**
2. **Doc as Code https://www.writethedocs.org/guide/docs-as-code/**
3. **AsciiDoc https://asciidoctor.org/docs/what-is-asciidoc/**
4. **ARC42 https://arc42.org/why**

## Guide
1. **ASCIIDOC refer to https://docs.asciidoctor.org/asciidoc/latest/syntax-quick-reference/**
2. **ARC42 template refer to https://docs.arc42.org/section-1/**
3. **C4 Model refer to https://c4model.com/#References**
4. **Theming guide refer to https://github.com/asciidoctor/asciidoctor-pdf/blob/main/docs/theming-guide.adoc#attribute-references**

## Setup 
1. **Install jq, ruby (> 2.5), ruby-bundler, pandoc(latest), rsvg-convert**
2. **Run bundle config set --local path .bundle/gems && bundle**
3. **sudo apt-get install language-pack-zh***
4. **sudo apt-get install fonts-arphic-ukai fonts-arphic-uming fonts-ipafont-mincho fonts-ipafont-gothic fonts-unfonts-core**
5. **sudo snap install drawio**
6. **VSCode as default IDE**

## Build 
1. **make , possible args QC_ARCH=8295 or 8155**

## Build Manually
1. **bundle exec asciidoctor-pdf -a pdf-theme=./theme/chronicles-theme.yml index.adoc**
2. **Check directory build**
