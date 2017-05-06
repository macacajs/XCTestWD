all: install
install:
	carthage update --platform iOS
build: install
	xcodebuild -project ./XCTestWD/XCTestWD.xcodeproj -sdk iphonesimulator
.PHONY: test
