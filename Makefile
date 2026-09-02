install:
	cp -R *.cgroups *.types ananicy.conf 00-default /etc/ananicy.d/
lint:
	python lint.py
