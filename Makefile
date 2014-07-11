deploy:
	@rm -rf ./_site
	@jekyll build
	@cd ./_site && git init . && git add . && git commit -nm \"Deployment\" && \
	git push "git@github.com:robertkowalski/robert-kowalski.de.git" master:gh-pages --force && rm -rf .git
	@rm -rf ./_site
