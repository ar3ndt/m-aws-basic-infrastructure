ROOT_DIR := $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST)))))

VERSION ?= 0.0.1
USER := epiphanyplatform
IMAGE := awsbi
IMAGE_NAME := $(USER)/$(IMAGE):$(VERSION)
#used for correctly setting shared folder permissions
HOST_UID := $(shell id -u)
HOST_GID := $(shell id -g)

.PHONY: build release metadata

warning:
	$(error Usage: make (build/release/metadata) )

build: guard-VERSION guard-IMAGE guard-USER
	docker build --rm \
		--build-arg ARG_M_VERSION=$(VERSION) \
		--build-arg ARG_HOST_UID=$(HOST_UID) \
		--build-arg ARG_HOST_GID=$(HOST_GID) \
		-t $(IMAGE_NAME) \
		.

release: guard-VERSION guard-IMAGE guard-USER
	docker build \
		--build-arg ARG_M_VERSION=$(VERSION) \
		-t $(IMAGE_NAME) \
		.

guard-%:
	@if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* not set"; \
		exit 1; \
	fi

metadata: guard-IMAGE
	docker run --rm \
		-t $(IMAGE_NAME) \
		metadata
