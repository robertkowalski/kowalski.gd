test:
	@open http://localhost:4000
	@jekyll serve -w

deploy:
	@rm -rf ./_site
	@jekyll build
	@mkdir -p _site/assets && cp -r assets _site/assets && cp CNAME _site/CNAME
	@cd ./_site && git init . && git add . && git commit -nm \"Deployment\" && \
	git push "git@github.com:robertkowalski/robert-kowalski.de.git" master:gh-pages --force && rm -rf .git
	@rm -rf ./_site
