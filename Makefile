# Thin entry point: this device's base is kept by tad; the standing tables follow grenudi/ideal-knowledge-base.
SHELL := /bin/bash
TAD ?= tad
export DOCS_FORMAT ?= md

.PHONY: setup check canon render verify
setup:            ## install tad and ikb from their pinned releases (checksums checked)
	./bin/install-tad.sh
	$(TAD) engine
	sh bin/install-ikb.sh
check:            ## every row and every rule across tables (tables.toml)
	$(TAD) check
canon:            ## rewrite the data in canonical form
	$(TAD) canon
render:           ## render the pages from the data
	$(TAD) render
verify: check     ## what CI runs: data is valid and canonical, docs are fresh
	@before="$$(find data docs -type f -print0 2>/dev/null | sort -z | xargs -0 sha256sum 2>/dev/null)"; \
	$(TAD) canon && $(TAD) render; \
	after="$$(find data docs -type f -print0 | sort -z | xargs -0 sha256sum)"; \
	if [ "$$before" != "$$after" ]; then \
	  echo "data/ or docs/ was not canonical/fresh and has been rewritten. Review and commit:"; \
	  diff <(echo "$$before") <(echo "$$after") || true; exit 1; \
	fi; echo "verify: data canonical, docs fresh"
