#
# make luatex
#

build:
	docker build -t xdvipsk --platform linux/amd64 .

linux-build:
	docker run --rm --platform linux/amd64 --user $(shell id -u):$(shell id -g) \
	    -v ./source/:/usr/local/src xdvipsk

run:
	docker run -i -t --platform linux/amd64 --user $(shell id -u):$(shell id -g) \
	    -v ./source/:/usr/local/src xdvipsk /bin/bash
