DOCKER?=docker

# Inputs
SOURCE_REPO?=registry.suse.com/suse/sl-micro/6.1/baremetal-os-container
SOURCE_VERSION?=2.2.0-3.12
ELEMENTAL_TOOLKIT_REPO?=ghcr.io/rancher/elemental-toolkit/elemental-cli
ELEMENTAL_TOOLKIT_VERSION?=v2.2.0

# Outputs
ELEMENTAL_BUILD?=dev
ELEMENTAL_REPO?=ghcr.io/max06/elemental-wiit
ELEMENTAL_TAG?=$(SOURCE_VERSION)-$(ELEMENTAL_TOOLKIT_VERSION)-$(ELEMENTAL_BUILD)

.PHONY: build-base-os
build-base-os:
	$(DOCKER) build \
			--build-arg ELEMENTAL_TOOLKIT=$(ELEMENTAL_TOOLKIT_REPO):$(ELEMENTAL_TOOLKIT_VERSION) \
			--build-arg SOURCE_REPO=$(SOURCE_REPO) \
			--build-arg SOURCE_VERSION=$(SOURCE_VERSION) \
			--build-arg ELEMENTAL_REPO=$(ELEMENTAL_REPO) \
			--build-arg ELEMENTAL_TAG=$(ELEMENTAL_TAG) \
			-t $(ELEMENTAL_REPO)/base-os:$(ELEMENTAL_TAG) \
			$(if $(GITHUB_RUN_NUMBER),--push) \
			-f Dockerfile.base.os .

.PHONY: build-bare-metal-os
build-bare-metal-os:
	$(DOCKER) build \
			--build-arg ELEMENTAL_BASE=$(ELEMENTAL_REPO)/base-os:$(ELEMENTAL_TAG) \
			-t $(ELEMENTAL_REPO)/bare-metal-os:$(ELEMENTAL_TAG) \
			$(if $(GITHUB_RUN_NUMBER),--push) \
			-f Dockerfile.bare-metal.os .

.PHONY: build-bare-metal-iso
build-bare-metal-iso:
	$(DOCKER) build \
			--build-arg ELEMENTAL_BASE=$(ELEMENTAL_REPO)/bare-metal-os:$(ELEMENTAL_TAG) \
			-t $(ELEMENTAL_REPO)/bare-metal-iso:$(ELEMENTAL_TAG) \
			$(if $(GITHUB_RUN_NUMBER),--push) \
			-f Dockerfile.bare-metal.iso .

.PHONY: debug
debug:
	echo "Hello there"
	echo "The value is $(if $(GITHUB_RUN_NUMBER),there!)"
