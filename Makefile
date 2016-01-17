
deps:
ifeq (, $(shell which html-minifier))
	npm i -g html-minifier
endif
ifeq (, $(shell which cleancss))
	npm i -g clean-css
endif
ifeq (, $(shell which critical))
	npm i -g critical
endif


test: deps build
	@open http://localhost:8000
	@cd _site && python -m "SimpleHTTPServer"

build: clean
	bundle exec jekyll build
	mkdir -p _site/assets && cp -r assets _site/assets && cp CNAME _site/CNAME && cp .nojekyll _site/.nojekyll
	cd _site && cleancss -o assets/css/styles-min.css assets/themes/tom/css/syntax.css assets/themes/tom/css/screen.css assets/css/additional-styles.css
	for file in $(shell find _site -name '*.html') ; do \
		cat $$file | critical --inline -c _site/assets/css/styles-min.css --dest $$file; \
		html-minifier --remove-comments --collapse-whitespace --remove-attribute-quotes --collapse-boolean-attributes --use-short-doctype --remove-script-type-attributes --remove-style-link-type-attributes --remove-optional-tags -o $$file $$file; \
	done

deploy: deps build
	@cd ./_site && git init . && git add . && git commit -nm \"Deployment\" && \
	git push "git@github.com:robertkowalski/kowalski.gd.git" master:gh-pages --force && rm -rf .git

clean:
	rm -rf ./_site
	rm -f tmp-*

.PHONY: build deps clean
