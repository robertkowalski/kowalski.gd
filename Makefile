
deps:
ifeq (, $(shell which html-minifier))
	npm i -g clean-css html-minifier
endif
ifeq (, $(shell which cleancss))
	npm i -g clean-css
endif


test: deps
	cleancss -o assets/css/styles-min.css assets/themes/tom/css/syntax.css assets/themes/tom/css/screen.css assets/css/additional-styles.css
	@open http://localhost:4000
	@jekyll serve -w

deploy: deps
	@rm -rf ./_site
	@jekyll build
	@mkdir -p _site/assets && cp -r assets _site/assets && cp CNAME _site/CNAME
	@cd _site && cleancss -o assets/css/styles-min.css assets/themes/tom/css/syntax.css assets/themes/tom/css/screen.css assets/css/additional-styles.css
	for file in $(shell find _site -name '*.html') ; do \
		html-minifier --remove-comments --collapse-whitespace --remove-attribute-quotes --collapse-boolean-attributes --use-short-doctype --remove-script-type-attributes --remove-style-link-type-attributes --remove-optional-tags -o $$file $$file; \
	done
	@cd ./_site && git init . && git add . && git commit -nm \"Deployment\" && \
	git push "git@github.com:robertkowalski/robert-kowalski.de.git" master:gh-pages --force && rm -rf .git
	@rm -rf ./_site
