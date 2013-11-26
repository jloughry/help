readme = README.md

all:
	@echo "There is nothing to build in this directory."

vi:
	vi $(readme)

spell:
	aspell --lang=en_GB check $(readme)

clean:
	@echo "\"make clean\" doesn't do anything here."

include common.mk

