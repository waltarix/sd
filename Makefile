ifeq ($(RUST_TARGET),)
	TARGET :=
	RELEASE_SUFFIX :=
else
	TARGET := $(RUST_TARGET)
	RELEASE_SUFFIX := -$(TARGET)
	export CARGO_BUILD_TARGET = $(RUST_TARGET)
endif

PROJECT_NAME := sd

_HASH   := \#
VERSION := $(lastword $(subst $(_HASH), ,$(shell cargo pkgid -p $(PROJECT_NAME))))
RELEASE := $(PROJECT_NAME)-$(VERSION)$(RELEASE_SUFFIX)

DIST_DIR        := dist
RELEASE_DIR     := $(DIST_DIR)/$(RELEASE)
ASSETS_DIR      := $(RELEASE_DIR)/gen
MANUAL_DIR      := $(ASSETS_DIR)
COMPLETIONS_DIR := $(ASSETS_DIR)/completions

BINARY      := target/$(TARGET)/release/$(PROJECT_NAME)
MANUAL      := gen/$(PROJECT_NAME).1
COMPLETIONS := $(addprefix gen/completions/, \
									_$(PROJECT_NAME) \
									_$(PROJECT_NAME).ps1 \
									$(PROJECT_NAME).bash \
									$(PROJECT_NAME).elv \
									$(PROJECT_NAME).fish \
								)

ASSETS := $(MANUAL) $(COMPLETIONS)

RELEASE_BINARY      := $(RELEASE_DIR)/$(PROJECT_NAME)
RELEASE_MANUAL      := $(ASSETS_DIR)/$(notdir $(MANUAL))
RELEASE_COMPLETIONS := $(addprefix $(COMPLETIONS_DIR)/,$(notdir $(COMPLETIONS)))

ARTIFACT := $(RELEASE).tar.xz

.PHONY: all
all: $(ARTIFACT)

$(BINARY):
	cargo build --locked --release

$(ASSETS) &:
	cargo xtask gen

$(DIST_DIR) $(RELEASE_DIR) $(ASSETS_DIR) $(COMPLETIONS_DIR):
	mkdir -p $@

$(RELEASE_BINARY): $(BINARY) $(RELEASE_DIR)
	cp -f $< $@
$(RELEASE_MANUAL): $(MANUAL) $(ASSETS_DIR)
	cp -f $< $@
$(RELEASE_COMPLETIONS) &: $(COMPLETIONS) $(COMPLETIONS_DIR)
	cp -f $(COMPLETIONS) $(COMPLETIONS_DIR)

$(ARTIFACT): $(RELEASE_BINARY) $(RELEASE_MANUAL) $(RELEASE_COMPLETIONS)
	tar -C $(DIST_DIR) -Jcvf $@ $(RELEASE)

.PHONY: clean
clean:
	$(RM) -r $(ARTIFACT) $(DIST_DIR)
