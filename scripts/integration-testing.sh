#!/bin/bash

brew install nvm > /dev/null 2>&1
source $(brew --prefix nvm)/nvm.sh
nvm install 8

export XCTESTWD_PATH=`pwd`"/XCTestWD/XCTestWD.xcodeproj"

echo process env XCTESTWD_PATH set to $XCTESTWD_PATH

# temporary fix before fixing macaca-scripts
brew install ios-webkit-debug-proxy > /dev/null 2>&1

git clone https://github.com/macaca-sample/sample-nodejs.git --depth=1
cd sample-nodejs

npm i
npm install macaca-ios -g
npm run test:ios
