build:
	docker build \
		-t cgit:latest \
		-f Dockerfile .
.PHONY: build
