PATH := ./node_modules/.bin:${PATH}

all: build

init: node_modules

node_modules: package.json
	npm install
	touch node_modules

clean:
	rm -rf dist/

build: init
	node_modules/.bin/coffee -o dist/ -c src/

test: init
	npm test

dist: build
	npm pack

publish: dist
	npm publish

.PHONY: doc build dist publich clean init all
