SHELL := bash

DOCKER_USER := ingy
DOCKER_NAME := $(shell git config -f .bpan/config package.name)-base
DOCKER_TAG := $(shell git config -f .bpan/config package.version)
DOCKER_IMAGE := $(DOCKER_USER)/$(DOCKER_NAME):$(DOCKER_TAG)

test ?= test/

default:

.PHONY: test
test:
	prove -v $(test)

docker-build:
	docker build \
	    --file=Dockerfile.base \
	    --tag="$(DOCKER_IMAGE)" \
	    .

docker-push: docker-build
	docker push $(DOCKER_IMAGE)
