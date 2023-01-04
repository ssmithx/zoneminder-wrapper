DOC_ASSETS := $(shell find ./docs/assets)
PKG_VERSION := $(shell cat manifest.json | jq -r '.version')
UPSTREAM_VERSION :=$(shell ./utils/get_upstream_version.sh ${PKG_VERSION})
PKG_ID := $(shell cat manifest.json | jq -r '.id')
TS_FILES := $(shell find ./ -name \*.ts)

.DELETE_ON_ERROR:

all: verify

# assumes /etc/embassy/config.yaml exists on local system with `host: "http://embassy-server-name.local"` configured
install: $(PKG_ID).s9pk
	embassy-cli package install $(PKG_ID).s9pk

verify: $(PKG_ID).s9pk
	embassy-sdk verify s9pk $(PKG_ID).s9pk

clean:
	rm -rf docker-images
	rm -f  $(PKG_ID).s9pk
	rm -f image.tar
	rm -f scripts/*.js

$(PKG_ID).s9pk: manifest.json LICENSE instructions.md icon.png scripts/embassy.js docker-images/aarch64.tar docker-images/x86_64.tar
	if ! [ -z "$(ARCH)" ]; then cp docker-images/$(ARCH).tar image.tar; fi
	embassy-sdk pack

instructions.md: docs/instructions.md $(DOC_ASSETS)
	cd docs && md-packer < instructions.md > ../instructions.md

 docker-images/aarch64.tar: Dockerfile docker_entrypoint.sh manifest.json
	mkdir -p docker-images
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --build-arg DB=sqlite --build-arg PLATFORM=arm64 --tag start9/$(PKG_ID)/main:$(PKG_VERSION) --platform=linux/arm64/v8 -o type=docker,dest=docker-images/aarch64.tar -f Dockerfile .

 docker-images/x86_64.tar: Dockerfile docker_entrypoint.sh manifest.json
	mkdir -p docker-images
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --build-arg DB=sqlite --build-arg PLATFORM=amd64 --tag start9/$(PKG_ID)/main:$(PKG_VERSION) --platform=linux/amd64 -o type=docker,dest=docker-images/x86_64.tar -f Dockerfile .

scripts/embassy.js: $(TS_FILES) scripts/generated/manifest.ts
	deno bundle scripts/embassy.ts scripts/embassy.js

scripts/generated/manifest.ts: manifest.json
	mkdir -p scripts/generated
	deno run --allow-write scripts/generators/generateManifest.ts

LICENSE:
	wget https://raw.githubusercontent.com/ZoneMinder/zoneminder/$(UPSTREAM_VERSION)/LICENSE -O - > LICENSE
