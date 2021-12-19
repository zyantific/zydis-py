PY := ".venv/bin/python3"
PIP := ".venv/bin/pip"

first:
	@echo "No default -- please select a specific make rule!"

update-enums:
	# Explicitly don't use the venv here -- use system python that hopefully has libclang.
	cd ../zydis-bindgen && /usr/bin/python gen.py "$(CURDIR)/zydis-c" pxd > "$(CURDIR)/zydis/cenums.pxd"
	cd ../zydis-bindgen && /usr/bin/python gen.py "$(CURDIR)/zydis-c" py > "$(CURDIR)/zydis/pyenums.py"

.venv:
	python3 -mvenv .venv
	$(PIP) install cython ipython

develop: .venv
	$(PY) setup.py build_clib
	$(PY) setup.py develop
	@echo 'Done. Activate env by running `source .venv/bin/activate` now.'

clean: .venv
	$(PY) setup.py clean

distclean: clean
	rm -rf .venv
	rm -rf ./build
	rm -rf ./dist
	rm -rf zydis_py.egg-info
	rm zydis/zydis.c
	rm zydis/zydis.cpython-*.so

test: develop
	$(PY) -munittest -v
