DATE=$(shell date +"%a %b %d %Y")

all: ~/rpmbuild/SPECS/openmodelica-1.11.spec
~/rpmbuild/SPECS/openmodelica-1.11.spec: SPECS/openmodelica.spec.tpl
	sed -e s/BRANCH/1.11/ -e s/VERSION/1.11.0/ -e 's/DATE/$(DATE)/' -e 's/RELEASENUM/1/' $< > $@.tmp
	mv $@.tmp $@
