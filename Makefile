ifeq ($(RUST_TARGET),)
	TARGET :=
	RELEASE_SUFFIX :=
else
	TARGET := $(RUST_TARGET)
	RELEASE_SUFFIX := -$(TARGET)
	export CARGO_BUILD_TARGET = $(RUST_TARGET)
endif

PROJECT_NAME := sd

VERSION := $(subst $\",,$(word 3,$(shell grep -m1 "^version" Cargo.toml)))
RELEASE := $(PROJECT_NAME)-$(VERSION)$(RELEASE_SUFFIX)

DIST_DIR := dist
RELEASE_DIR := $(DIST_DIR)/$(RELEASE)
MANUAL_DIR := $(RELEASE_DIR)/manual

BINARY := target/$(TARGET)/release/$(PROJECT_NAME)
MANUAL := $(PROJECT_NAME).1

RELEASE_BINARY := $(RELEASE_DIR)/$(PROJECT_NAME)
RELEASE_MANUAL := $(MANUAL_DIR)/$(MANUAL)

ARTIFACT := $(RELEASE).tar.xz

.PHONY: all
all: $(ARTIFACT)

$(BINARY) $(MANUAL) &:
	cargo build --locked --release

$(DIST_DIR) $(RELEASE_DIR) $(MANUAL_DIR):
	mkdir -p $@

$(RELEASE_BINARY): $(BINARY) $(RELEASE_DIR)
	cp -f $< $@
$(RELEASE_MANUAL): $(MANUAL) $(MANUAL_DIR)
	cp -f $< $@

$(ARTIFACT): $(RELEASE_BINARY) $(RELEASE_MANUAL)
	tar -C $(DIST_DIR) -Jcvf $@ $(RELEASE)

.PHONY: clean
clean:
	$(RM) -r $(ARTIFACT) $(DIST_DIR)
