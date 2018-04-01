#!/bin/bash

brew install ios-webkit-debug-proxy > /dev/null 2>&1
brew install nvm > /dev/null 2>&1
source $(brew --prefix nvm)/nvm.sh
nvm install 8

git clone https://github.com/macaca-sample/sample-nodejs.git --depth=1
cd sample-nodejs

npm i
npm run test:ios
