.PHONY: build
build: src/App.elm
	elm make src/App.elm --output=dist/index.html
