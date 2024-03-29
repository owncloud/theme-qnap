SHELL := /bin/bash

app_name=$(notdir $(CURDIR))
build_dir=$(CURDIR)/build
dist_dir=$(build_dir)/dist
src_files=CHANGELOG.md README.md defaults.php
src_dirs=appinfo core
all_src=$(src_dirs) $(src_files)
package_name?=$(app_name)

occ=$(CURDIR)/../../occ
private_key?=$(HOME)/.owncloud/certificates/$(app_name).key
certificate?=$(HOME)/.owncloud/certificates/$(app_name).crt
sign=$(occ) integrity:sign-app --privateKey="$(private_key)" --certificate="$(certificate)"
sign_skip_msg="Skipping signing, either no key and certificate found in $(private_key) and $(certificate) or occ can not be found at $(occ)"
ifneq (,$(wildcard $(private_key)))
ifneq (,$(wildcard $(certificate)))
ifneq (,$(wildcard $(occ)))
	CAN_SIGN=true
endif
endif
endif

.DEFAULT_GOAL := help

help:
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

##
## Build targets
##--------------------------------------

.PHONY: dist
dist:                       ## Build distribution
dist: distdir sign package


.PHONY: distdir
distdir:
	rm -rf "$(dist_dir)"
	mkdir -p "$(dist_dir)/$(app_name)"
	cp -R $(all_src) "$(dist_dir)/$(app_name)"

.PHONY: sign
sign:
ifdef CAN_SIGN
	$(sign) --path="$(dist_dir)/$(app_name)"
else
	@echo $(sign_skip_msg)
endif

.PHONY: package
package:
	tar -czf "$(dist_dir)/$(package_name).tar.gz" -C "$(dist_dir)" "$(app_name)"
