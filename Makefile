DOCKER?=docker

# Inputs
ELEMENTAL_TOOLKIT_REPO?=ghcr.io/rancher/elemental-toolkit/elemental-cli
ELEMENTAL_TOOLKIT_VERSION?=v2.2.1
#RANCHER_SYSTEM_AGENT_VERSION?=v0.3.4
#ELEMENTAL_REGISTER?=WHERE_TO GET? https://github.com/rancher/elemental-operator/blob/main/Dockerfile

# Outputs
ELEMENTAL_BUILD?=dev
ELEMENTAL_REPO?=ghcr.io/kbudde/elemental-wiit
ELEMENTAL_TAG?=$(ELEMENTAL_TOOLKIT_VERSION)-$(ELEMENTAL_BUILD)

.PHONY: build-base-os
build-base-os:
	$(DOCKER) build \
			--build-arg ELEMENTAL_TOOLKIT=$(ELEMENTAL_TOOLKIT_REPO):$(ELEMENTAL_TOOLKIT_VERSION) \
			--build-arg REPO=$(ELEMENTAL_REPO)/base-os \
			--build-arg VERSION=$(ELEMENTAL_TAG) \
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
