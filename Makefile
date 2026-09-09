.PHONY: install lint

install:
	mkdir -p $(DESTDIR)/etc/ananicy.d
	cp -R *.cgroups *.types ananicy.conf 00-default $(DESTDIR)/etc/ananicy.d/

lint:
	python lint.py
