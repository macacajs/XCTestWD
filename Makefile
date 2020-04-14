install:
	carthage update --platform iOS --verbose
debug:
	carthage build --configuration Debug
.PHONY: coverage
